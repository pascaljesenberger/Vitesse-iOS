//
//  CandidatesToolbar.swift
//  vitesse
//
//  Created by pascal jesenberger on 07/03/2025.
//

import SwiftUI

struct CandidatesToolbar: View {
    @ObservedObject var viewModel: CandidateViewModel
    
    var body: some View {
        HStack {
            Button(viewModel.isEditing ? "Cancel" : "Edit") {
                viewModel.isEditing.toggle()
            }
            .foregroundColor(.black)
            
            Spacer()
            
            Text("Candidates")
                .font(.system(size: 20, weight: .bold))
            
            Spacer()
            
            if viewModel.isEditing {
                Button("Delete") {
                    viewModel.isEditing.toggle()
                    // et supprimer
                }
                .foregroundColor(.black)
            } else {
                Button {
                    viewModel.isFavoritesFiltering.toggle()
                    // filtre les candidats si ils sont favoris ou non
                } label: {
                    Image(systemName: viewModel.isFavoritesFiltering ? "star.fill" : "star")
                }
                
                .foregroundColor(.black)
            }
        }
    }
}
