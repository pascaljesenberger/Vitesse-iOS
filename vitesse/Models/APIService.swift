//
//  APIService.swift
//  vitesse
//
//  Created by pascal jesenberger on 28/02/2025.
//

import Foundation

class APIService {
    // Singleton pour partager une instance unique de APIService
    static let shared = APIService()
    
    // URL de base de l'API
    private let baseURL = "http://127.0.0.1:8080"
    
    // MARK: - Auth Methods
    
    /// Authentifie un utilisateur avec un email et un mot de passe
    func authenticate(email: String, password: String) async throws -> AuthResponse {
        let url = URL(string: "\(baseURL)/user/auth")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Structure du corps de la requête
        let body = ["email": email, "password": password]
        let jsonData = try JSONEncoder().encode(body)
        request.httpBody = jsonData
        
        print("🔐 Authenticate - Request URL: \(url)")
        print("🔐 Authenticate - Request Body: \(String(data: jsonData, encoding: .utf8) ?? "unable to read")")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            print("🔐 Authenticate - Response: \(response)")
            print("🔐 Authenticate - Response Data: \(String(data: data, encoding: .utf8) ?? "unable to read")")
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🔐 Authenticate - Status Code: \(httpResponse.statusCode)")
                
                // Vérifie si le statut HTTP est différent de 200 (succès)
                if httpResponse.statusCode != 200 {
                    throw APIError.loginFailed
                }
            }
            
            // Décode la réponse JSON en un objet AuthResponse
            let decoder = JSONDecoder()
            let authResponse = try decoder.decode(AuthResponse.self, from: data)
            print("🔐 Authentication successful: token=\(authResponse.token.prefix(10))... isAdmin=\(authResponse.isAdmin)")
            return authResponse
        } catch let decodingError as DecodingError {
            print("❌ Authenticate - Decoding Error: \(decodingError)")
            // Gestion des erreurs de décodage
            switch decodingError {
            case .keyNotFound(let key, _):
                print("❌ Missing key: \(key.stringValue)")
            case .typeMismatch(let type, _):
                print("❌ Type mismatch: \(type)")
            case .valueNotFound(let type, _):
                print("❌ Value not found: \(type)")
            case .dataCorrupted(let context):
                print("❌ Data corrupted: \(context.debugDescription)")
            @unknown default:
                print("❌ Unknown decoding error")
            }
            throw decodingError
        } catch {
            print("❌ Authenticate - General Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Enregistre un nouvel utilisateur
    func register(firstName: String, lastName: String, email: String, password: String) async throws {
        let url = URL(string: "\(baseURL)/user/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Structure du corps de la requête
        let body = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "password": password
        ]
        
        let jsonData = try JSONEncoder().encode(body)
        request.httpBody = jsonData
        
        print("📝 Register - Request URL: \(url)")
        print("📝 Register - Request Body: \(String(data: jsonData, encoding: .utf8) ?? "unable to read")")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        print("📝 Register - Response: \(response)")
        print("📝 Register - Response Data: \(String(data: data, encoding: .utf8) ?? "no data")")
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Register - Invalid HTTP Response")
            throw APIError.invalidResponse
        }
        
        print("📝 Register - Status Code: \(httpResponse.statusCode)")
        
        // Vérifie si le statut HTTP est 201 (créé)
        guard httpResponse.statusCode == 201 else {
            print("❌ Register - Failed with status code: \(httpResponse.statusCode)")
            throw APIError.registrationFailed
        }
        
        print("✅ Registration successful")
    }
    
    // MARK: - Candidate Methods
    
    /// Récupère tous les candidats
    func getAllCandidates() async throws -> [Candidate] {
        // Vérifie la présence du token d'authentification
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("❌ GetAllCandidates - No token found")
            throw APIError.noToken
        }
        
        let url = URL(string: "\(baseURL)/candidate")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("👥 GetAllCandidates - Request URL: \(url)")
        print("👥 GetAllCandidates - Token: \(token.prefix(10))...")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            print("👥 GetAllCandidates - Response: \(response)")
            print("👥 GetAllCandidates - Response Data: \(String(data: data, encoding: .utf8) ?? "unable to read")")
            
            if let httpResponse = response as? HTTPURLResponse {
                print("👥 GetAllCandidates - Status Code: \(httpResponse.statusCode)")
                
                // Gestion des erreurs d'autorisation
                if httpResponse.statusCode == 401 {
                    throw APIError.notAuthorized
                } else if httpResponse.statusCode != 200 {
                    throw APIError.invalidResponse
                }
            }
            
            // Décode la réponse JSON en une liste de candidats
            let candidates = try JSONDecoder().decode([Candidate].self, from: data)
            print("✅ Retrieved \(candidates.count) candidates")
            return candidates
        } catch let decodingError as DecodingError {
            print("❌ GetAllCandidates - Decoding Error: \(decodingError)")
            // Gestion des erreurs de décodage
            switch decodingError {
            case .keyNotFound(let key, _):
                print("❌ Missing key: \(key.stringValue)")
            case .typeMismatch(let type, _):
                print("❌ Type mismatch: \(type)")
            case .valueNotFound(let type, _):
                print("❌ Value not found: \(type)")
            case .dataCorrupted(let context):
                print("❌ Data corrupted: \(context.debugDescription)")
            @unknown default:
                print("❌ Unknown decoding error")
            }
            throw decodingError
        } catch {
            print("❌ GetAllCandidates - General Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Récupère un candidat spécifique par son ID
    func getCandidate(id: String) async throws -> Candidate {
        // Vérifie la présence du token d'authentification
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("❌ GetCandidate - No token found")
            throw APIError.noToken
        }
        
        let url = URL(string: "\(baseURL)/candidate/\(id)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("👤 GetCandidate - Request URL: \(url)")
        print("👤 GetCandidate - Token: \(token.prefix(10))...")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            print("👤 GetCandidate - Response: \(response)")
            print("👤 GetCandidate - Response Data: \(String(data: data, encoding: .utf8) ?? "unable to read")")
            
            if let httpResponse = response as? HTTPURLResponse {
                print("👤 GetCandidate - Status Code: \(httpResponse.statusCode)")
                
                // Gestion des erreurs d'autorisation
                if httpResponse.statusCode == 401 {
                    throw APIError.notAuthorized
                } else if httpResponse.statusCode != 200 {
                    throw APIError.invalidResponse
                }
            }
            
            // Décode la réponse JSON en un objet Candidate
            let candidate = try JSONDecoder().decode(Candidate.self, from: data)
            print("✅ Retrieved candidate: \(candidate.firstName) \(candidate.lastName)")
            return candidate
        } catch let decodingError as DecodingError {
            print("❌ GetCandidate - Decoding Error: \(decodingError)")
            // Gestion des erreurs de décodage
            switch decodingError {
            case .keyNotFound(let key, _):
                print("❌ Missing key: \(key.stringValue)")
            case .typeMismatch(let type, _):
                print("❌ Type mismatch: \(type)")
            case .valueNotFound(let type, _):
                print("❌ Value not found: \(type)")
            case .dataCorrupted(let context):
                print("❌ Data corrupted: \(context.debugDescription)")
            @unknown default:
                print("❌ Unknown decoding error")
            }
            throw decodingError
        } catch {
            print("❌ GetCandidate - General Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Met à jour les informations d'un candidat
    func updateCandidate(id: String, firstName: String, lastName: String, email: String, phone: String?, note: String?, linkedinURL: String?) async throws -> Candidate {
        // Vérifie la présence du token d'authentification
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("❌ UpdateCandidate - No token found")
            throw APIError.noToken
        }
        
        let url = URL(string: "\(baseURL)/candidate/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Structure du corps de la requête avec des champs optionnels
        var body: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email
        ]
        
        // Ajoute les champs optionnels seulement s'ils existent
        if let phone = phone { body["phone"] = phone }
        if let note = note { body["note"] = note }
        if let linkedinURL = linkedinURL { body["linkedinURL"] = linkedinURL }
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        request.httpBody = jsonData
        
        print("📝 UpdateCandidate - Request URL: \(url)")
        print("📝 UpdateCandidate - Request Body: \(String(data: jsonData, encoding: .utf8) ?? "unable to read")")
        print("📝 UpdateCandidate - Token: \(token.prefix(10))...")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            print("📝 UpdateCandidate - Response: \(response)")
            print("📝 UpdateCandidate - Response Data: \(String(data: data, encoding: .utf8) ?? "unable to read")")
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📝 UpdateCandidate - Status Code: \(httpResponse.statusCode)")
                
                // Gestion des erreurs d'autorisation
                if httpResponse.statusCode == 401 {
                    throw APIError.notAuthorized
                } else if httpResponse.statusCode != 200 {
                    throw APIError.candidateUpdateFailed
                }
            }
            
            // Décode la réponse JSON en un objet Candidate
            let candidate = try JSONDecoder().decode(Candidate.self, from: data)
            print("✅ Updated candidate: \(candidate.firstName) \(candidate.lastName)")
            return candidate
        } catch let decodingError as DecodingError {
            print("❌ UpdateCandidate - Decoding Error: \(decodingError)")
            // Gestion des erreurs de décodage
            switch decodingError {
            case .keyNotFound(let key, _):
                print("❌ Missing key: \(key.stringValue)")
            case .typeMismatch(let type, _):
                print("❌ Type mismatch: \(type)")
            case .valueNotFound(let type, _):
                print("❌ Value not found: \(type)")
            case .dataCorrupted(let context):
                print("❌ Data corrupted: \(context.debugDescription)")
            @unknown default:
                print("❌ Unknown decoding error")
            }
            throw decodingError
        } catch {
            print("❌ UpdateCandidate - General Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Supprime un candidat par son ID
    func deleteCandidate(id: String) async throws {
        // Vérifie la présence du token d'authentification
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("❌ DeleteCandidate - No token found")
            throw APIError.noToken
        }
        
        let url = URL(string: "\(baseURL)/candidate/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("🗑️ DeleteCandidate - Request URL: \(url)")
        print("🗑️ DeleteCandidate - Token: \(token.prefix(10))...")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        print("🗑️ DeleteCandidate - Response: \(response)")
        print("🗑️ DeleteCandidate - Response Data: \(String(data: data, encoding: .utf8) ?? "no data")")
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ DeleteCandidate - Invalid HTTP Response")
            throw APIError.invalidResponse
        }
        
        print("🗑️ DeleteCandidate - Status Code: \(httpResponse.statusCode)")
        
        // Vérifie si le statut HTTP est 200 (succès)
        guard httpResponse.statusCode == 200 else {
            print("❌ DeleteCandidate - Failed with status code: \(httpResponse.statusCode)")
            if httpResponse.statusCode == 401 {
                throw APIError.notAuthorized
            } else {
                throw APIError.candidateDeletionFailed
            }
        }
        
        print("✅ Deleted candidate with ID: \(id)")
    }
    
    /// Bascule le statut "favori" d'un candidat
    func toggleCandidateFavorite(id: String) async throws -> Candidate {
        // Vérifie la présence du token d'authentification
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("❌ ToggleFavorite - No token found")
            throw APIError.noToken
        }
        
        let url = URL(string: "\(baseURL)/candidate/\(id)/favorite")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("⭐ ToggleFavorite - Request URL: \(url)")
        print("⭐ ToggleFavorite - Token: \(token.prefix(10))...")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            print("⭐ ToggleFavorite - Response: \(response)")
            print("⭐ ToggleFavorite - Response Data: \(String(data: data, encoding: .utf8) ?? "unable to read")")
            
            if let httpResponse = response as? HTTPURLResponse {
                print("⭐ ToggleFavorite - Status Code: \(httpResponse.statusCode)")
                
                // Gestion des erreurs d'autorisation
                if httpResponse.statusCode == 401 {
                    throw APIError.notAuthorized
                } else if httpResponse.statusCode != 200 {
                    throw APIError.favoriteToggleFailed
                }
            }
            
            // Décode la réponse JSON en un objet Candidate
            let candidate = try JSONDecoder().decode(Candidate.self, from: data)
            print("✅ Toggled favorite status for candidate: \(candidate.firstName) \(candidate.lastName)")
            return candidate
        } catch let decodingError as DecodingError {
            print("❌ ToggleFavorite - Decoding Error: \(decodingError)")
            // Gestion des erreurs de décodage
            switch decodingError {
            case .keyNotFound(let key, _):
                print("❌ Missing key: \(key.stringValue)")
            case .typeMismatch(let type, _):
                print("❌ Type mismatch: \(type)")
            case .valueNotFound(let type, _):
                print("❌ Value not found: \(type)")
            case .dataCorrupted(let context):
                print("❌ Data corrupted: \(context.debugDescription)")
            @unknown default:
                print("❌ Unknown decoding error")
            }
            throw decodingError
        } catch {
            print("❌ ToggleFavorite - General Error: \(error.localizedDescription)")
            throw error
        }
    }
}

// MARK: - APIError

/// Enumération des erreurs possibles de l'API
enum APIError: Error {
    case noToken
    case loginFailed
    case registrationFailed
    case candidateCreationFailed
    case candidateUpdateFailed
    case candidateDeletionFailed
    case favoriteToggleFailed
    case invalidResponse
    case notAuthorized
    
    var localizedDescription: String {
        switch self {
        case .noToken:
            return "Authentication error: No token found"
        case .loginFailed:
            return "Login failed"
        case .registrationFailed:
            return "Registration failed"
        case .candidateCreationFailed:
            return "Candidate creation failed"
        case .candidateUpdateFailed:
            return "Candidate update failed"
        case .candidateDeletionFailed:
            return "Candidate deletion failed"
        case .favoriteToggleFailed:
            return "Failed to toggle favorite status"
        case .invalidResponse:
            return "Invalid server response"
        case .notAuthorized:
            return "You are not authorized to perform this action"
        }
    }
}
