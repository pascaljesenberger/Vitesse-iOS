//
//  LoginViewModel.swift
//  vitesse
//
//  Created by pascal jesenberger on 28/02/2025.
//

import Foundation

class LoginViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published var hasEmptyFields: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var isLoggedIn: Bool = false
    @Published var isAdmin: Bool = false
    
    // MARK: - Validation Methods
    func validateEmptyFields() {
        hasEmptyFields = email.isEmpty || password.isEmpty
    }
    
    var isFormValid: Bool {
        return !email.isEmpty && !password.isEmpty
    }
    
    // MARK: - Authentication
    @MainActor
    func login() {
        // Validate form before attempting login
        validateEmptyFields()
        
        guard isFormValid else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                // Authenticate and store user session data
                let response = try await APIService.shared.authenticate(email: email, password: password)
                UserDefaults.standard.set(response.token, forKey: "authToken")
                UserDefaults.standard.set(response.isAdmin, forKey: "isAdmin")
                self.isAdmin = response.isAdmin
                self.isLoggedIn = true
                print("Login successful for: \(email)")
            } catch APIError.loginFailed {
                self.error = "Invalid email/username or password. Please check your credentials and try again."
                print("Login failed: Invalid credentials")
            } catch APIError.invalidResponse {
                self.error = "The server returned an unexpected response. Please try again later."
                print("Login error: Invalid server response")
            } catch APIError.notAuthorized {
                self.error = "You are not authorized to access this application."
                print("Login error: Not authorized")
            } catch {
                self.error = "An error occurred: \(error.localizedDescription)"
                print("Login error: \(error.localizedDescription)")
            }
            self.isLoading = false
        }
    }
}
