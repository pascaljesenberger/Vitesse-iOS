//
//  CandidatesListView.swift
//  vitesse
//
//  Created by pascal jesenberger on 28/02/2025.
//

import SwiftUI

struct CandidatesListView: View {
    @StateObject private var viewModel = CandidateViewModel()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchBar(text: $viewModel.searchText)
                            .padding(.horizontal)
                            .padding(.bottom)
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .padding()
                } else if viewModel.filteredCandidates.isEmpty {
                    ScrollView {
                        Text("No candidates found")
                            .foregroundColor(.gray)
                            .padding()
                    }
                    .refreshable {
                        await viewModel.loadCandidates()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.filteredCandidates) { candidate in
                                CandidateRow(
                                    firstName: candidate.firstName,
                                    lastName: candidate.lastName,
                                    email: candidate.email,
                                    isFavorite: candidate.isFavorite,
                                    isSelected: viewModel.isSelected(candidate.id),
                                    isEditing: viewModel.isEditing,
                                    onToggleFavorite: {
                                        toggleFavorite(candidate.id)
                                    },
                                    onToggleSelection: {
                                        viewModel.toggleSelection(candidate.id)
                                    }
                                )
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        await viewModel.loadCandidates()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    CandidatesToolbar(
                        viewModel: viewModel,
                        onDelete: deleteSelectedCandidates
                    )
                }
            }
            .navigationBarBackButtonHidden(true)
            .alert(alertMessage, isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            }
            .onAppear {
                viewModel.loadCandidates()
                viewModel.checkAdminStatus()
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
    
    private func deleteSelectedCandidates() {
        viewModel.deleteSelectedCandidates()
    }
}

#Preview {
    CandidatesListView()
}
