import SwiftUI

// MARK: - Filtre alcool
enum AlcoholFilter: String, CaseIterable {
    case all
    case alcoholic
    case nonAlcoholic
}

@MainActor
final class ExploreViewModel: ObservableObject {

    // MARK: - Données principales
    @Published var drinks: [Drink] = []

    // MARK: - États UI
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Recherche
    @Published var searchText: String = ""

    // MARK: - Filtres
    @Published var alcoholFilter: AlcoholFilter = .all
    @Published var categoryFilter: String = "ALL"
    @Published var glassFilter: String = "ALL"

    private let service = CocktailService()

    // MARK: - Catégories disponibles
    var availableCategories: [String] {
        let categories = drinks.compactMap {
            $0.strCategory?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return Array(Set(categories)).sorted()
    }

    // MARK: - Verres disponibles
    var availableGlasses: [String] {
        let glasses = drinks.compactMap {
            $0.strGlass?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return Array(Set(glasses)).sorted()
    }

    // MARK: - Liste filtrée affichée dans la View
    var filteredDrinks: [Drink] {
        let query = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        return drinks.filter { drink in

            // 1️⃣ Recherche par nom
            let matchesSearch =
                query.isEmpty ||
                drink.strDrink.lowercased().contains(query)

            // 2️⃣ Filtre alcool
            let alcoholicValue = (drink.strAlcoholic ?? "").lowercased()
            let matchesAlcohol: Bool = {
                switch alcoholFilter {
                case .all:
                    return true
                case .alcoholic:
                    return alcoholicValue.contains("alcoholic")
                        && !alcoholicValue.contains("non")
                case .nonAlcoholic:
                    return alcoholicValue.contains("non")
                }
            }()

            // 3️⃣ Filtre catégorie
            let drinkCategory = (drink.strCategory ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            let matchesCategory =
                categoryFilter == "ALL" || drinkCategory == categoryFilter

            // 4️⃣ Filtre verre
            let drinkGlass = (drink.strGlass ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            let matchesGlass =
                glassFilter == "ALL" || drinkGlass == glassFilter

            return matchesSearch
                && matchesAlcohol
                && matchesCategory
                && matchesGlass
        }
    }

    // MARK: - Reset filtres
    func resetFilters() {
        alcoholFilter = .all
        categoryFilter = "ALL"
        glassFilter = "ALL"
    }

    // MARK: - Chargement API
    func loadDrinks() async {
        guard drinks.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        do {
            let result = try await service.fetchDrinks()
            self.drinks = result
        } catch {
            self.errorMessage = "Erreur : \(error)"
        }

        isLoading = false
    }
}
