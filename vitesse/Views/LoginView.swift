//
//  LoginView.swift
//  vitesse
//
//  Created by pascal jesenberger on 20/02/2025.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var navigateToCandidatesList = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    Image("vitesse_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 54)
                        .padding(.top, 40)
                        .padding(.bottom, 10)
                    
                    Text("Login")
                        .font(.system(size: 56, weight: .semibold))
                        .padding(.bottom, 20)
                    
                    VStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            CustomTextField(
                                topText: "Email/Username",
                                TextFieldText: $viewModel.email,
                                placeholder: "Enter your email or username"
                            )
                            .onChange(of: viewModel.email) {
                                viewModel.validateEmptyFields()
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            CustomTextField(
                                topText: "Password",
                                TextFieldText: $viewModel.password,
                                placeholder: "Enter your password",
                                isSecure: true
                            )
                            .onChange(of: viewModel.password) {
                                viewModel.validateEmptyFields()
                            }
                        }
                    }
                    
                    if viewModel.hasEmptyFields {
                        Text("Please fill in all fields")
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 8)
                    }
                    
                    if let error = viewModel.error {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 8)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                    
                    CustomButton(
                        text: "Sign in",
                        action: {
                            viewModel.login()
                        },
                        isLoading: viewModel.isLoading
                    )
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                    .opacity(viewModel.isFormValid && !viewModel.isLoading ? 1.0 : 0.5)
                    .padding(.bottom)
                    
                    NavigationLink {
                        RegisterView()
                    } label: {
                        Text("Register")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 184, height: 64)
                            .background(.black)
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 26)
                .background(Color.white)
                .navigationDestination(isPresented: $navigateToCandidatesList) {
                    CandidatesListView()
                }
                .onChange(of: viewModel.isLoggedIn) {
                    if viewModel.isLoggedIn {
                        navigateToCandidatesList = true
                    }
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
