import Foundation
import SwiftUI

@MainActor
final class FavoritesStore: ObservableObject {
    @Published private(set) var favorites: [Drink] = [] {
        didSet { save() } // dès que ça change, on sauvegarde
    }

    private let storageKey = "favorites_drinks_v1"

    init() {
        load()
    }

    func isFavorite(_ drink: Drink) -> Bool {
        favorites.contains(where: { $0.idDrink == drink.idDrink })
    }

    func toggle(_ drink: Drink) {
        if isFavorite(drink) {
            favorites.removeAll { $0.idDrink == drink.idDrink }
        } else {
            favorites.insert(drink, at: 0)
        }
    }

    func remove(_ drink: Drink) {
        favorites.removeAll { $0.idDrink == drink.idDrink }
    }

    func removeAll() {
        favorites.removeAll()
    }

    // MARK: - Persistence

    private func save() {
        do {
            let data = try JSONEncoder().encode(favorites)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("❌ FavoritesStore save error:", error)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }

        do {
            favorites = try JSONDecoder().decode([Drink].self, from: data)
        } catch {
            print("❌ FavoritesStore load error:", error)
            favorites = []
        }
    }
}
