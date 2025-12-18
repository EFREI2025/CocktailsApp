import SwiftUI

struct ExploreView: View {
    @StateObject var viewModel = ExploreViewModel()

    // UI state pour afficher la sheet
    @State private var showFilters = false

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

            // 🔍 Recherche
            .searchable(text: $viewModel.searchText, prompt: "Rechercher un cocktail")

            // 👉 Destination unique pour les cocktails
            .navigationDestination(for: Drink.self) { drink in
                DrinkDetailView(drink: drink)
            }

            // ⭐ + 🧰
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        FavoritesView()
                    } label: {
                        Image(systemName: "star")
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showFilters = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    .accessibilityLabel("Filtres")
                }
            }

            // 🧾 Sheet filtres
            .sheet(isPresented: $showFilters) {
                NavigationStack {
                    Form {
                        Section("Type") {
                            Picker("Alcohol", selection: $viewModel.alcoholFilter) {
                                Text("Tous").tag(AlcoholFilter.all)
                                Text("Alcoholic").tag(AlcoholFilter.alcoholic)
                                Text("Non alcoholic").tag(AlcoholFilter.nonAlcoholic)
                            }
                            .pickerStyle(.segmented)
                        }

                        Section("Catégorie") {
                            Picker("Catégorie", selection: $viewModel.categoryFilter) {
                                Text("Toutes").tag("ALL")
                                ForEach(viewModel.availableCategories, id: \.self) { cat in
                                    Text(cat).tag(cat)
                                }
                            }
                        }
                        
                        Section("Verre") {
                            Picker("Type de verre", selection:$viewModel.glassFilter) {
                                Text("ALL").tag("ALL")
                                ForEach(viewModel.availableGlasses, id: \.self) { glass in
                                    Text(glass).tag(glass)}
                            }
                        }

                        Section {
                            Button(role: .destructive) {
                                viewModel.resetFilters()
                            } label: {
                                Text("Réinitialiser les filtres")
                            }
                        }
                    }
                    .navigationTitle("Filtres")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("OK") { showFilters = false }
                        }
                    }
                }
            }

            // 🌐 Chargement
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
