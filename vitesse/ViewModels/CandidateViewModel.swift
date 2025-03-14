//
//  CandidateViewModel.swift
//  vitesse
//
//  Created by pascal jesenberger on 28/02/2025.
//

import Foundation
import Combine

class CandidateViewModel: ObservableObject {
    @Published var candidates: [Candidate] = []
    @Published var selectedCandidate: Candidate?
    @Published var candidateId: String?
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var isAdmin: Bool = false
    @Published var isEditing = false
    @Published var isEditingCandidate = false
    @Published var isFavoritesFiltering = false
    @Published var searchText: String = ""
    @Published var selectedCandidateIds: Set<String> = []
    
    private var cancellables = Set<AnyCancellable>()
    
    var filteredCandidates: [Candidate] {
        candidates.filter { candidate in
            let nameMatch = searchText.isEmpty ||
                            candidate.firstName.lowercased().contains(searchText.lowercased()) ||
                            candidate.lastName.lowercased().contains(searchText.lowercased()) ||
                            candidate.email.lowercased().contains(searchText.lowercased())
            
            let favoriteMatch = !isFavoritesFiltering || candidate.isFavorite
            
            return nameMatch && favoriteMatch
        }
    }
    
    init() {
        checkAdminStatus()
    }
    
    func checkAdminStatus() {
        // Force a re-read from UserDefaults
        if let isAdmin = UserDefaults.standard.object(forKey: "isAdmin") as? Bool {
            self.isAdmin = isAdmin
            print("Admin status checked: \(isAdmin)")
        } else {
            print("No admin status found in UserDefaults")
        }
    }
    
    func isSelected(_ candidateId: String) -> Bool {
        return selectedCandidateIds.contains(candidateId) && isEditing
    }
    
    func toggleSelection(_ candidateId: String) {
        if selectedCandidateIds.contains(candidateId) {
            selectedCandidateIds.remove(candidateId)
        } else {
            selectedCandidateIds.insert(candidateId)
        }
    }
    
    func clearSelection() {
        selectedCandidateIds.removeAll()
    }
    
    @MainActor
    func deleteSelectedCandidates() {
        guard !selectedCandidateIds.isEmpty else { return }
        
        // Create a copy to avoid modification during iteration
        let candidatesToDelete = selectedCandidateIds
        
        // Reset selection immediately for better UX
        selectedCandidateIds.removeAll()
        
        // Now the view will update, then exit edit mode after deletions complete
        isEditing = false
        
        // Delete each candidate
        for id in candidatesToDelete {
            deleteCandidate(id: id) { _ in
                // Success/failure handling is done in the deleteCandidate method
            }
        }
    }
    
    @MainActor
    func loadCandidates() {
        isLoading = true
        error = nil
        
        Task {
            do {
                candidates = try await APIService.shared.getAllCandidates()
            } catch {
                self.error = "Impossible de charger les candidats: \(error.localizedDescription)"
                print("Load candidates error: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
    
    @MainActor
    func loadCandidate(id: String) {
        isLoading = true
        error = nil
        
        Task {
            do {
                selectedCandidate = try await APIService.shared.getCandidate(id: id)
            } catch {
                self.error = "Impossible de charger le candidat: \(error.localizedDescription)"
                print("Load candidate error: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
    
    @MainActor
    func createCandidate(firstName: String, lastName: String, email: String, phone: String?, note: String?, linkedinURL: String?, completion: @escaping (Bool) -> Void) {
        isLoading = true
        error = nil
        
        Task {
            do {
                let newCandidate = try await APIService.shared.createCandidate(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    phone: phone,
                    note: note,
                    linkedinURL: linkedinURL
                )
                
                candidates.append(newCandidate)
                completion(true)
            } catch {
                self.error = "Impossible de créer le candidat: \(error.localizedDescription)"
                print("Create candidate error: \(error.localizedDescription)")
                completion(false)
            }
            isLoading = false
        }
    }
    
    @MainActor
    func updateCandidate(id: String, firstName: String, lastName: String, email: String, phone: String?, note: String?, linkedinURL: String?, completion: @escaping (Bool) -> Void) {
        isLoading = true
        error = nil
        
        Task {
            do {
                let updatedCandidate = try await APIService.shared.updateCandidate(
                    id: id,
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    phone: phone,
                    note: note,
                    linkedinURL: linkedinURL
                )
                
                if let index = candidates.firstIndex(where: { $0.id == id }) {
                    candidates[index] = updatedCandidate
                }
                
                if selectedCandidate?.id == id {
                    selectedCandidate = updatedCandidate
                }
                
                completion(true)
            } catch {
                self.error = "Impossible de mettre à jour le candidat: \(error.localizedDescription)"
                print("Update candidate error: \(error.localizedDescription)")
                completion(false)
            }
            isLoading = false
        }
    }
        
        @MainActor
        func deleteCandidate(id: String, completion: @escaping (Bool) -> Void) {
            isLoading = true
            error = nil
            
            Task {
                do {
                    try await APIService.shared.deleteCandidate(id: id)
                    
                    candidates.removeAll { $0.id == id }
                    
                    if selectedCandidate?.id == id {
                        selectedCandidate = nil
                    }
                    
                    completion(true)
                } catch {
                    self.error = "Impossible de supprimer le candidat: \(error.localizedDescription)"
                    print("Delete candidate error: \(error.localizedDescription)")
                    completion(false)
                }
                isLoading = false
            }
        }
        
        @MainActor
        func toggleFavorite(id: String, completion: @escaping (Bool) -> Void) {
            let isAdmin = UserDefaults.standard.bool(forKey: "isAdmin")
            
            guard isAdmin else {
                error = "You need to be an admin to mark candidates as favorites."
                completion(false)
                return
            }
            
            isLoading = true
            error = nil
            
            Task {
                do {
                    let updatedCandidate = try await APIService.shared.toggleCandidateFavorite(id: id)
                    
                    if let index = candidates.firstIndex(where: { $0.id == id }) {
                        candidates[index] = updatedCandidate
                    }
                    
                    if selectedCandidate?.id == id {
                        selectedCandidate = updatedCandidate
                    }
                    
                    completion(true)
                } catch {
                    self.error = "Impossible de modifier le statut favori: \(error.localizedDescription)"
                    print("Toggle favorite error: \(error.localizedDescription)")
                    completion(false)
                }
                isLoading = false
            }
        }
    }
