//
//  ContactInfoRow.swift
//  vitesse
//
//  Created by pascal jesenberger on 14/03/2025.
//

import SwiftUI

struct ContactInfoRow: View {
    let label: String
    let value: String
    let isLinkedIn: Bool
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
            
            Spacer()
            
            if isLinkedIn {
                Button(action: {
                    if let url = URL(string: value), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Go on LinkedIn")
                        .font(.system(size: 14))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 1)
                                .background(Color.blue.opacity(0.1))
                        )
                }
            } else {
                Text(value)
                    .font(.system(size: 14))
            }
        }
        .padding(.vertical, 6)
    }
}
