import Foundation

@MainActor
final class FavoritesStore: ObservableObject {
    @Published private(set) var favorites: [Drink] = []

    func isFavorite(_ drink: Drink) -> Bool {
        favorites.contains(where: { $0.idDrink == drink.idDrink })
    }

    func toggle(_ drink: Drink) {
        if let index = favorites.firstIndex(where: { $0.idDrink == drink.idDrink }) {
            favorites.remove(at: index)
        } else {
            favorites.insert(drink, at: 0)
        }
    }
}
