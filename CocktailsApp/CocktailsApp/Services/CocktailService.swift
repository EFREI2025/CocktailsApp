//
//  CocktailService.swift
//  CocktailsApp
//
//  Created by Georgy GUEI on 12/17/25.
//

import Foundation

enum CocktailError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
}

public struct Config {
    // TheCocktailDB provides a public test key "1". Replace with your own if needed.
    public static let CocktailToken: String = "1"
}

class CocktailService {
    private let apiKey = Config.CocktailToken

    func fetchDrinks() async throws -> [Drink] {
        let letters = "abcdefghijklmnopqrstuvwxyz"
        var allDrinks: [Drink] = []
        
        // Fetch drinks for each letter
        for letter in letters {
            let urlString = "https://www.thecocktaildb.com/api/json/v1/\(apiKey)/search.php?f=\(letter)"
            
            guard let url = URL(string: urlString) else {
                throw CocktailError.invalidURL
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            // Appel réseau async/await
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Vérification de la réponse HTTP
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw CocktailError.invalidResponse
            }
            
            do {
                let decoded = try JSONDecoder().decode(DrinkResponse.self, from: data)
                // Some API responses may omit the drinks array for a given letter. If your model defines `drinks` as optional, use `?? []`.
                // If it's non-optional, this still compiles and simply appends the array.
                allDrinks.append(contentsOf: decoded.drinks ?? [])
            } catch {
                throw CocktailError.decodingError
            }
        }
        
        print("Fetched \(allDrinks.count) total drinks from A to Z")
        return allDrinks
    }
}

