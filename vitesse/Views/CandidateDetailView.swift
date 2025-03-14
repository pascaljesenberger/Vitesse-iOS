//
//  CandidateDetailView.swift
//  vitesse
//
//  Created by pascal jesenberger on 07/03/2025.
//

import SwiftUI

struct CandidateDetailView: View {
    let candidate: Candidate
    @StateObject private var viewModel = CandidateViewModel()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("\(candidate.firstName) \(candidate.lastName)")
                        .font(.system(size: 20, weight: .bold))
                    
                    Spacer()
                    
                    Button(action: { toggleFavorite(candidate.id) }) {
                        Image(systemName: candidate.isFavorite ? "star.fill" : "star")
                            .foregroundColor(candidate.isFavorite ? .black : .gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
                
                if let phone = candidate.phone {
                    ContactInfoRow(label: "Phone", value: phone, isLinkedIn: false)
                }
                
                ContactInfoRow(label: "Email", value: candidate.email, isLinkedIn: false)
                
                if let linkedinURL = candidate.linkedinURL {
                    ContactInfoRow(label: "LinkedIn", value: linkedinURL, isLinkedIn: true)
                }
                
                if let note = candidate.note, !note.isEmpty {
                    NoteSection(noteText: note)
                        .padding(.top, 8)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .toolbar {
                CandidateToolbar(viewModel: viewModel)
            }
            .navigationBarBackButtonHidden(true)
            .alert(alertMessage, isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }
    
    private func toggleFavorite(_ id: String) {
        viewModel.toggleFavorite(id: id) { success in
            if !success {
                alertMessage = "You need to be an admin to mark candidates as favorites."
                showingAlert = true
            }
        }
    }
}
