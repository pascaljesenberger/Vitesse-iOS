//
//  Models.swift
//  vitesse
//
//  Created by pascal jesenberger on 28/02/2025.
//

import Foundation

struct AuthResponse: Codable {
    let token: String
    let isAdmin: Bool
}

struct Candidate: Codable, Identifiable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let phone: String?
    let note: String?
    let linkedinURL: String?
    let isFavorite: Bool
}
