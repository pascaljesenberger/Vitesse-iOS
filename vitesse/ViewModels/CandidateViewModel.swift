//
//  CandidateViewModel.swift
//  vitesse
//
//  Created by pascal jesenberger on 28/02/2025.
//

import Foundation
import Combine

class CandidateViewModel: ObservableObject {
    // MARK: - Published Properties
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
    
    // MARK: - Computed Properties
    var filteredCandidates: [Candidate] {
        candidates.filter { candidate in
            // Filter by search text (name or email)
            let nameMatch = searchText.isEmpty ||
            candidate.firstName.lowercased().contains(searchText.lowercased()) ||
            candidate.lastName.lowercased().contains(searchText.lowercased()) ||
            candidate.email.lowercased().contains(searchText.lowercased())
            
            // Filter by favorites if enabled
            let favoriteMatch = !isFavoritesFiltering || candidate.isFavorite
            
            return nameMatch && favoriteMatch
        }
    }
    
    // MARK: - Initialization
    init() {
        checkAdminStatus()
    }
    
    // MARK: - Admin Functions
    func checkAdminStatus() {
        if let isAdmin = UserDefaults.standard.object(forKey: "isAdmin") as? Bool {
            self.isAdmin = isAdmin
            print("Admin status checked: \(isAdmin)")
        } else {
            print("No admin status found in UserDefaults")
        }
    }
    
    // MARK: - Validation Methods
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func isValidPhoneNumber(_ phone: String) -> Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone)
    }
    
    // MARK: - Selection Handling
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
    
    // MARK: - Batch Operations
    @MainActor
    func deleteSelectedCandidates() {
        guard !selectedCandidateIds.isEmpty else { return }
        
        let candidatesToDelete = selectedCandidateIds
        
        selectedCandidateIds.removeAll()
        isEditing = false
        
        // Delete each selected candidate
        for id in candidatesToDelete {
            deleteCandidate(id: id) { _ in
            }
        }
    }
    
    // MARK: - API Operations
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
                
                // Update local data after successful API call
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
                
                // Remove from local data after successful API call
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
        // Check admin status before allowing favorite toggling
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
                
                // Update local data after successful API call
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
