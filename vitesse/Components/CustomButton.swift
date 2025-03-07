//
//  CustomButton.swift
//  vitesse
//
//  Created by pascal jesenberger on 20/02/2025.
//

import SwiftUI

struct CustomButton: View {
    var text: String
    var action: (() -> Void)
    var isLoading: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(text)
                        .font(.system(size: 22, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(width: 184, height: 64)
            .background(.black)
            .cornerRadius(10)
        }
    }
}

#Preview {
    CustomButton(text: "Send") {
        print("Button tapped!")
    }
}
