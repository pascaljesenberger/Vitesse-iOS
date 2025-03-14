//
//  CandidatesToolbar.swift
//  vitesse
//
//  Created by pascal jesenberger on 07/03/2025.
//

import SwiftUI

struct CandidatesToolbar: ToolbarContent {
    @ObservedObject var viewModel: CandidateViewModel
    let onDelete: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(viewModel.isEditing ? "Cancel" : "Edit") {
                viewModel.isEditing.toggle()
                if !viewModel.isEditing {
                    viewModel.clearSelection()
                }
            }
            .foregroundColor(.black)
        }
        
        ToolbarItem(placement: .principal) {
            Text("Candidates")
                .font(.system(size: 20, weight: .bold))
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            if viewModel.isEditing {
                Button("Delete") {
                    onDelete()
                }
                .foregroundColor(.red)
                .disabled(viewModel.selectedCandidateIds.isEmpty)
            } else {
                Button {
                    viewModel.isFavoritesFiltering.toggle()
                } label: {
                    Image(systemName: viewModel.isFavoritesFiltering ? "star.fill" : "star")
                        .foregroundColor(viewModel.isFavoritesFiltering ? .black : .gray)
                }
            }
        }
    }
}
