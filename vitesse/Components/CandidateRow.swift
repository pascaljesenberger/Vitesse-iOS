//
//  CandidateRow.swift
//  vitesse
//
//  Created by pascal jesenberger on 07/03/2025.
//

import SwiftUI

struct CandidateRow: View {
    let firstName: String
    let lastName: String
    let email: String
    let isFavorite: Bool
    let isSelected: Bool
    let isEditing: Bool
    let onToggleFavorite: () -> Void
    let onToggleSelection: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggleSelection) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .opacity(isEditing ? 1 : 0)
            
            VStack(alignment: .leading) {
                Text("\(firstName) \(lastName)")
                    .foregroundColor(.black)
                    .font(.system(size: 16, weight: .medium))
                
                Text(email)
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            }
            .padding(.leading, isEditing ? 0 : 8)
            
            Spacer()
            
            if !isEditing {
                Button(action: onToggleFavorite) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundColor(isFavorite ? .black : .gray)
                }
                .padding()
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, minHeight: 60)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1)
                )
        )
    }
}
