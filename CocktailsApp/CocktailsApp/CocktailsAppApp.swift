import SwiftUI

@main
struct CocktailsAppApp: App {
    @StateObject private var favoritesStore = FavoritesStore()

    var body: some Scene {
        WindowGroup {
            ExploreView()
                .environmentObject(favoritesStore)
        }
    }
}
