import SwiftUI

@main
struct CocktailsAppApp: App {
    @StateObject private var favoritesStore = FavoritesStore()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ExploreView()
            }
            .environmentObject(favoritesStore)
        }
    }
}
