//
//  RegisterView.swift
//  vitesse
//
//  Created by pascal jesenberger on 20/02/2025.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    Text("Register")
                        .font(.system(size: 40, weight: .bold))
                        .padding(.bottom, 20)
                    
                    VStack(spacing: 12) {
                        CustomTextField(
                            topText: "First Name",
                            TextFieldText: $viewModel.firstName,
                            placeholder: "Enter your first name"
                        )
                        .onChange(of: viewModel.firstName) {
                            viewModel.validateEmptyFields()
                        }
                        
                        CustomTextField(
                            topText: "Last Name",
                            TextFieldText: $viewModel.lastName,
                            placeholder: "Enter your last name"
                        )
                        .onChange(of: viewModel.lastName) {
                            viewModel.validateEmptyFields()
                        }
                        
                        VStack(alignment: .leading) {
                            CustomTextField(
                                topText: "Email",
                                TextFieldText: $viewModel.email,
                                placeholder: "Enter your email"
                            )
                            .onChange(of: viewModel.email) {
                                viewModel.validateEmail()
                                viewModel.validateEmptyFields()
                            }
                            
                            if !viewModel.isEmailValid {
                                Text("Invalid email")
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(.leading, 4)
                            }
                        }
                        
                        CustomTextField(
                            topText: "Password",
                            TextFieldText: $viewModel.password,
                            placeholder: "Enter your password",
                            isSecure: true
                        )
                        .onChange(of: viewModel.password) {
                            viewModel.validatePasswords()
                            viewModel.validateEmptyFields()
                        }
                        
                        VStack(alignment: .leading) {
                            CustomTextField(
                                topText: "Confirm Password",
                                TextFieldText: $viewModel.confirmPassword,
                                placeholder: "Confirm your password",
                                isSecure: true
                            )
                            .onChange(of: viewModel.confirmPassword) {
                                viewModel.validatePasswords()
                                viewModel.validateEmptyFields()
                            }
                            
                            if !viewModel.passwordsMatch && !viewModel.confirmPassword.isEmpty {
                                Text("Passwords do not match")
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(.leading, 4)
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
                        text: "Create",
                        action: {
                            viewModel.register()
                        },
                        isLoading: viewModel.isLoading
                    )
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                    .opacity(viewModel.isFormValid && !viewModel.isLoading ? 1.0 : 0.5)
                    
                    Spacer()
                }
                .padding(.horizontal, 26)
                .background(Color.white)
                .onChange(of: viewModel.isRegistered) {
                    if viewModel.isRegistered {
                        showSuccessAlert = true
                    }
                }
                .alert("Account Created", isPresented: $showSuccessAlert) {
                    Button("OK") {
                        dismiss()
                    }
                } message: {
                    Text("Your account has been successfully created. You can now login.")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    BackButton {
                        dismiss()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    RegisterView()
}
