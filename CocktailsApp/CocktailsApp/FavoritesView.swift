import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesStore: FavoritesStore

    var body: some View {
        Group {
            if favoritesStore.favorites.isEmpty {
                ContentUnavailableView("Aucun favori", systemImage: "star")
            } else {
                List(favoritesStore.favorites) { drink in
                    NavigationLink {
                        DrinkDetailView(drink: drink)
                    } label: {
                        DrinkRowView(drink: drink)
                    }
                }
            }
        }
        .navigationTitle("Favoris")
    }
}
