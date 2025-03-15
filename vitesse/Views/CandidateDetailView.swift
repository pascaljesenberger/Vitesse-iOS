//
//  CandidateDetailView.swift
//  vitesse
//
//  Created by pascal jesenberger on 07/03/2025.
//

import SwiftUI

struct CandidateDetailView: View {
    let candidate: Candidate
    @ObservedObject private var viewModel: CandidateViewModel
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var note: String = ""
    @State private var linkedinURL: String = ""
    
    init(candidate: Candidate, viewModel: CandidateViewModel) {
        self.candidate = candidate
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                if viewModel.isEditingCandidate {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("First Name")
                            .font(.system(size: 14))
                        TextField("First Name", text: $firstName)
                            .font(.system(size: 14))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                        
                        Text("Last Name")
                            .font(.system(size: 14))
                        TextField("Last Name", text: $lastName)
                            .font(.system(size: 14))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                    .padding(.bottom)
                } else {
                    HStack {
                        Text("\(viewModel.selectedCandidate?.firstName ?? candidate.firstName) \(viewModel.selectedCandidate?.lastName ?? candidate.lastName)")
                            .font(.system(size: 20, weight: .bold))
                        
                        Spacer()
                        
                        Button(action: { toggleFavorite(candidate.id) }) {
                            Image(systemName: (viewModel.selectedCandidate?.isFavorite ?? candidate.isFavorite) ? "star.fill" : "star")
                                .foregroundColor((viewModel.selectedCandidate?.isFavorite ?? candidate.isFavorite) ? .black : .gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                if viewModel.isEditingCandidate {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Phone")
                            .font(.system(size: 14))
                        TextField("Phone", text: $phone)
                            .font(.system(size: 14))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                    .padding(.bottom)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.system(size: 14))
                        TextField("Email", text: $email)
                            .font(.system(size: 14))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                    .padding(.bottom)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("LinkedIn URL")
                            .font(.system(size: 14))
                        TextField("LinkedIn URL", text: $linkedinURL)
                            .font(.system(size: 14))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                    .padding(.bottom)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note")
                            .font(.system(size: 14))
                        TextEditor(text: $note)
                            .font(.system(size: 14))
                            .padding()
                            .frame(height: 150)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                } else {
                    if let phone = viewModel.selectedCandidate?.phone ?? candidate.phone {
                        ContactInfoRow(label: "Phone", value: phone, isLinkedIn: false)
                    }
                    
                    ContactInfoRow(label: "Email", value: viewModel.selectedCandidate?.email ?? candidate.email, isLinkedIn: false)
                    
                    if let linkedinURL = viewModel.selectedCandidate?.linkedinURL ?? candidate.linkedinURL {
                        ContactInfoRow(label: "LinkedIn", value: linkedinURL, isLinkedIn: true)
                    }
                    
                    if let note = viewModel.selectedCandidate?.note ?? candidate.note, !note.isEmpty {
                        NoteSection(noteText: note)
                            .padding(.top, 8)
                    }
                }
                
                Spacer()
            }
            .padding(.top)
            .padding(.horizontal)
            .toolbar {
                CandidateToolbar(viewModel: viewModel, onSave: saveChanges)
            }
            .navigationBarBackButtonHidden(true)
            .alert(alertMessage, isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            }
            .onAppear {
                viewModel.loadCandidate(id: candidate.id)
                loadCandidateData()
            }
        }
    }
    
    private func loadCandidateData() {
        let candidateData = viewModel.selectedCandidate ?? candidate
        firstName = candidateData.firstName
        lastName = candidateData.lastName
        email = candidateData.email
        phone = candidateData.phone ?? ""
        note = candidateData.note ?? ""
        linkedinURL = candidateData.linkedinURL ?? ""
    }
    
    private func saveChanges() {
        if !viewModel.isValidEmail(email) {
            alertMessage = "Please enter a valid email address."
            showingAlert = true
            return
        }
        
        if !phone.isEmpty && !viewModel.isValidPhoneNumber(phone) {
            alertMessage = "Please enter a valid phone number."
            showingAlert = true
            return
        }
        
        viewModel.updateCandidate(
            id: candidate.id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone.isEmpty ? nil : phone,
            note: note.isEmpty ? nil : note,
            linkedinURL: linkedinURL.isEmpty ? nil : linkedinURL
        ) { success in
            if success {
                viewModel.isEditingCandidate = false
                
                viewModel.loadCandidate(id: candidate.id)
            } else {
                alertMessage = "Failed to update candidate: \(viewModel.error ?? "Unknown error")"
                showingAlert = true
            }
        }
    }
    
    private func toggleFavorite(_ id: String) {
        viewModel.toggleFavorite(id: id) { success in
            if success {
                viewModel.loadCandidate(id: candidate.id)
            } else {
                alertMessage = "You need to be an admin to mark candidates as favorites."
                showingAlert = true
            }
        }
    }
}
