//
//  CandidateDetailRow.swift
//  vitesse
//
//  Created by pascal jesenberger on 13/03/2025.
//

import SwiftUI

struct CandidateInfoRow: View {
    let title: String
    let value: String
    let isEditing: Bool
    var onValueChange: (String) -> Void = { _ in }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
            
            Spacer()
            
            if isEditing {
                TextField(title, text: Binding(
                    get: { value },
                    set: { onValueChange($0) }
                ))
                .font(.system(size: 18))
                .multilineTextAlignment(.trailing)
            } else {
                if title == "LinkedIn" && !value.isEmpty {
                    Text(value)
                        .font(.system(size: 18, weight: .semibold))
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.2))
                                .stroke(Color.black, lineWidth: 1)
                        )
                } else {
                    Text(value)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
        }
    }
}
