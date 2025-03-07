//
//  RegisterViewModel.swift
//  vitesse
//
//  Created by pascal jesenberger on 28/02/2025.
//

import Foundation

class RegisterViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    @Published var isEmailValid: Bool = true
    @Published var passwordsMatch: Bool = true
    @Published var hasEmptyFields: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var isRegistered: Bool = false
    
    func validateEmail() {
        isEmailValid = isValidEmail(email)
    }
    
    func validatePasswords() {
        passwordsMatch = password == confirmPassword && !password.isEmpty
    }
    
    func validateEmptyFields() {
        hasEmptyFields = firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    var isFormValid: Bool {
        return !firstName.isEmpty && !lastName.isEmpty && isEmailValid && passwordsMatch && !password.isEmpty && !confirmPassword.isEmpty
    }
    
    @MainActor
    func register() {
        validateEmptyFields()
        validateEmail()
        validatePasswords()
        
        guard isFormValid else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                try await APIService.shared.register(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    password: password
                )
                
                // After successful registration, we automatically log in
                let response = try await APIService.shared.authenticate(email: email, password: password)
                UserDefaults.standard.set(response.token, forKey: "authToken")
                UserDefaults.standard.set(response.isAdmin, forKey: "isAdmin")
                
                self.isRegistered = true
                print("Registration successful for: \(firstName) \(lastName), Email: \(email)")
            } catch {
                self.error = "An error occurred during registration. Please try again later."
                print("Registration error: \(error.localizedDescription)")
            }
            self.isLoading = false
        }
    }
}
