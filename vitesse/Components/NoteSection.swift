//
//  NoteSection.swift
//  vitesse
//
//  Created by pascal jesenberger on 14/03/2025.
//

import SwiftUI

struct NoteSection: View {
    let noteText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Note")
                .font(.system(size: 14))
            
            Text(noteText)
                .font(.system(size: 14))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 1)
                        )
                )
        }
    }
}
