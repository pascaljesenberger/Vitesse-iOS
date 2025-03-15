//
//  CandidateRow.swift
//  vitesse
//
//  Created by pascal jesenberger on 07/03/2025.
//

import SwiftUI

struct CandidateRow: View {
    let candidate: Candidate
    let isSelected: Bool
    let isEditing: Bool
    
    var onToggleFavorite: () -> Void = {}
    var onToggleSelection: () -> Void = {}

    var body: some View {
        NavigationLink(destination: CandidateDetailView(candidate: candidate, viewModel: CandidateViewModel())) {
            HStack {
                if isEditing {
                    Button(action: onToggleSelection) {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isSelected ? .blue : .gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(candidate.firstName) \(candidate.lastName)")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text(candidate.email)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if !isEditing {
                    Button(action: onToggleFavorite) {
                        Image(systemName: candidate.isFavorite ? "star.fill" : "star")
                            .foregroundColor(candidate.isFavorite ? .black : .gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
