
//
//  CocktailService.swift
//  CocktailSwift
//
//  Created by Georgy GUEI on 12/17/25.
//

class CocktailService {
    private let apiKey = Config.CocktailToken

    func fetchProducts() async throws -> [Drink] {
        let urlString = "https://www.thecocktaildb.com/api/json/v1/\(apiKey)/search.php?f=a"

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
            let decoded = try JSONDecoder().decode(ProductListResponse.self, from: data)
            print(decoded)
            return decoded.records
        } catch {
            throw CocktailError.decodingError
        }
    }
}
