import SwiftUI

struct ExploreView: View {
    @StateObject var viewModel = ExploreViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Chargement des cocktails...")
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if viewModel.drinks.isEmpty {
                    Text("Aucun cocktail disponible.")
                        .foregroundColor(.secondary)
                } else {
                    List(viewModel.filteredDrinks) { drink in
                        NavigationLink(value: drink) {
                            DrinkRowView(drink: drink)
                        }
                    }
                }
            }
            .navigationTitle("Explore")
            .searchable(text: $viewModel.searchText, prompt: "Rechercher un cocktail")

            // ✅ Routeur unique pour tous les NavigationLink(value: Drink)
            .navigationDestination(for: Drink.self) { drink in
                DrinkDetailView(drink: drink)
            }

            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        FavoritesView() // ✅ pas de NavigationStack dedans
                    } label: {
                        Image(systemName: "star")
                    }
                }
            }

            .task {
                await viewModel.loadDrinks()
            }
        }
    }
}

#Preview {
    ExploreView()
        .environmentObject(FavoritesStore())
}
