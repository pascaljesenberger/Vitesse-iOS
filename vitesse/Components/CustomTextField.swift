//
//  CustomTextField.swift
//  vitesse
//
//  Created by pascal jesenberger on 20/02/2025.
//

import SwiftUI

struct CustomTextField: View {
    var topText: String
    @Binding var TextFieldText: String
    var placeholder: String
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(topText)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black.opacity(0.6))
                .padding(.leading, 4)
            
            if isSecure {
                SecureField(placeholder, text: $TextFieldText)
                    .padding()
                    .frame(height: 52)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
                    )
            } else {
                TextField(placeholder, text: $TextFieldText)
                    .autocapitalization(.none)
                    .padding()
                    .frame(height: 52)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
                    )
            }
        }
        .padding(.bottom, 16)
    }
}
