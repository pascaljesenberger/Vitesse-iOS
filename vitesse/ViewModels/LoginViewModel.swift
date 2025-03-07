//
//  LoginViewModel.swift
//  vitesse
//
//  Created by pascal jesenberger on 28/02/2025.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published var isEmailValid: Bool = true
    @Published var hasEmptyFields: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var isLoggedIn: Bool = false
    @Published var isAdmin: Bool = false
    
    func validateEmail() {
        isEmailValid = isValidEmail(email)
    }
    
    func validateEmptyFields() {
        hasEmptyFields = email.isEmpty || password.isEmpty
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    var isFormValid: Bool {
        return !email.isEmpty && !password.isEmpty && isEmailValid
    }
    
    @MainActor
    func login() {
        validateEmptyFields()
        validateEmail()
        
        guard isFormValid else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                let response = try await APIService.shared.authenticate(email: email, password: password)
                UserDefaults.standard.set(response.token, forKey: "authToken")
                UserDefaults.standard.set(response.isAdmin, forKey: "isAdmin")
                self.isAdmin = response.isAdmin
                self.isLoggedIn = true
                print("Login successful for: \(email)")
            } catch {
                self.error = "An error occurred during login. Please try again later."
                print("Login error: \(error.localizedDescription)")
            }
            self.isLoading = false
        }
    }
}
