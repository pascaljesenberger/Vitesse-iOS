//
//  RegisterViewModel.swift
//  vitesse
//
//  Created by pascal jesenberger on 28/02/2025.
//

import Foundation

class RegisterViewModel: ObservableObject {
    // MARK: - Published Properties
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
    
    // MARK: - Validation Methods
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
    
    // MARK: - User Registration
    @MainActor
    func register() {
        // Validate form before attempting registration
        validateEmptyFields()
        validateEmail()
        validatePasswords()
        
        guard isFormValid else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                // Register new user
                try await APIService.shared.register(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    password: password
                )
                
                // Automatically log in after successful registration
                let response = try await APIService.shared.authenticate(email: email, password: password)
                UserDefaults.standard.set(response.token, forKey: "authToken")
                UserDefaults.standard.set(response.isAdmin, forKey: "isAdmin")
                
                self.isRegistered = true
                print("Registration successful for: \(firstName) \(lastName), Email: \(email)")
            } catch APIError.registrationFailed {
                self.error = "Registration failed. This email may already be registered."
                print("Registration error: Registration failed")
            } catch APIError.invalidResponse {
                self.error = "The server returned an unexpected response. Please try again later."
                print("Registration error: Invalid server response")
            } catch DecodingError.dataCorrupted(let context) {
                self.error = "Data corruption error: \(context.debugDescription)"
                print("Registration error: Data corrupted")
            } catch {
                self.error = "An error occurred: \(error.localizedDescription)"
                print("Registration error: \(error.localizedDescription)")
            }
            self.isLoading = false
        }
    }
}
