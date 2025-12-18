import SwiftUI

@MainActor
final class ExploreViewModel: ObservableObject {
    @Published var drinks: [Drink] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Optionnel (utile pour la barre de recherche)
    @Published var searchText: String = ""

    private let service = CocktailService()

    // Optionnel : ce que la View affiche réellement
    var filteredDrinks: [Drink] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return drinks }
        return drinks.filter { $0.strDrink.lowercased().contains(q) }
    }

    func loadDrinks() async {
        if drinks.isEmpty {
            isLoading = true
            errorMessage = nil

            do {
                // Charge une “page” de cocktails (ex: lettre A)
                let result = try await service.fetchDrinks()
                self.drinks = result
                self.isLoading = false
            } catch {
                self.errorMessage = "Erreur : \(error)"
                self.isLoading = false
            }
        }
    }
}
