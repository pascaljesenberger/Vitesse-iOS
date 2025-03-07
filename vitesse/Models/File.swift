//
//  File.swift
//  vitesse
//
//  Created by pascal jesenberger on 28/02/2025.
//
import Foundation

func fetchData() {
    let url = URL(string: "http://127.0.0.1:8080/")!

    // Création d'une tâche de session URL
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        // Vérification des erreurs
        if let error = error {
            print("Erreur: \(error.localizedDescription)")
            return
        }

        // Vérification de la réponse
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            print("Erreur de serveur!")
            return
        }

        // Vérification des données
        if let data = data, let responseString = String(data: data, encoding: .utf8) {
            print("Données reçues: \(responseString)")
        }
    }

    // Démarrage de la tâche
    task.resume()
}
