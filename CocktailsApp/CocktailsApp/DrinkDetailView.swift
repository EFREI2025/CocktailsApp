import SwiftUI

struct DrinkDetailView: View {
    let drink: Drink
    
    @EnvironmentObject var favoritesStore: FavoritesStore

    // Priorité FR, sinon EN
    private var instructionsToShow: String? {
        if let fr = drink.strInstructionsFR,
           !fr.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return fr
        }
        if let en = drink.strInstructions,
           !en.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return en
        }
        return nil
    }

    private var isFavorite: Bool {
        favoritesStore.isFavorite(drink)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // --- IMAGE ---
                if let urlString = drink.strDrinkThumb,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 350)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 350)
                                .overlay(Image(systemName: "photo.slash"))
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 300)
                }

                // --- CONTENU ---
                VStack(alignment: .leading, spacing: 20) {

                    // Catégorie + alcool
                    HStack {
                        if let category = drink.strCategory {
                            Text(category.uppercased())
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        let alcoholic = drink.strAlcoholic ?? "—"
                        Label(alcoholic, systemImage: "wineglass")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(
                                alcoholic.lowercased().contains("non") ? .blue : .orange
                            )
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                (alcoholic.lowercased().contains("non") ? Color.blue : Color.orange)
                                    .opacity(0.1)
                            )
                            .cornerRadius(8)
                    }

                    // Nom
                    Text(drink.strDrink)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    // Verre
                    if let glass = drink.strGlass {
                        HStack(spacing: 8) {
                            Image(systemName: "cup.and.saucer")
                                .foregroundColor(.secondary)
                            Text(glass)
                                .foregroundColor(.secondary)
                        }
                        .font(.subheadline)
                    }

                    Divider()

                    // Instructions
                    if let instructions = instructionsToShow {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Instructions")
                                .font(.headline)
                            Text(instructions)
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                        }
                    } else {
                        Text("Aucune instruction disponible.")
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // Ingrédients
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ingrédients")
                            .font(.headline)

                        if drink.ingredientLines.isEmpty {
                            Text("Aucun ingrédient disponible.")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(drink.ingredientLines, id: \.self) { line in
                                HStack {
                                    Text(line.name)
                                    Spacer()
                                    if let measure = line.measure, !measure.isEmpty {
                                        Text(measure)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .font(.subheadline)
                            }
                        }
                    }

                    Spacer(minLength: 30)

                    // --- BOUTON FAVORIS ---
                    Button {
                        favoritesStore.toggle(drink)
                    } label: {
                        Label(
                            isFavorite ? "Retirer des favoris" : "Ajouter aux favoris",
                            systemImage: isFavorite ? "star.fill" : "star"
                        )
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFavorite ? Color.red : Color.blue)
                        .cornerRadius(14)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .offset(y: -30)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color(UIColor.secondarySystemBackground))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let store = FavoritesStore()

    let drink = Drink(
        idDrink: "11007",
        strDrink: "Margarita",
        strDrinkAlternate: nil,
        strTags: nil,
        strVideo: nil,
        strCategory: "Cocktail",
        strIBA: nil,
        strAlcoholic: "Alcoholic",
        strGlass: "Cocktail glass",
        strInstructions: "Shake and strain into a chilled cocktail glass.",
        strInstructionsES: nil,
        strInstructionsDE: nil,
        strInstructionsFR: "Secouer et filtrer dans un verre à cocktail refroidi.",
        strInstructionsIT: nil,
        strInstructionsZH_HANS: nil,
        strInstructionsZH_HANT: nil,
        strDrinkThumb: "https://www.thecocktaildb.com/images/media/drink/5noda61589575158.jpg",
        strIngredient1: "Tequila",
        strIngredient2: "Triple sec",
        strIngredient3: "Lime juice",
        strIngredient4: "Salt",
        strIngredient5: nil,
        strIngredient6: nil,
        strIngredient7: nil,
        strIngredient8: nil,
        strIngredient9: nil,
        strIngredient10: nil,
        strIngredient11: nil,
        strIngredient12: nil,
        strIngredient13: nil,
        strIngredient14: nil,
        strIngredient15: nil,
        strMeasure1: "1 1/2 oz",
        strMeasure2: "1/2 oz",
        strMeasure3: "1 oz",
        strMeasure4: nil,
        strMeasure5: nil,
        strMeasure6: nil,
        strMeasure7: nil,
        strMeasure8: nil,
        strMeasure9: nil,
        strMeasure10: nil,
        strMeasure11: nil,
        strMeasure12: nil,
        strMeasure13: nil,
        strMeasure14: nil,
        strMeasure15: nil,
        strImageSource: nil,
        strImageAttribution: nil,
        strCreativeCommonsConfirmed: nil,
        dateModified: nil
    )

    return NavigationStack {
        DrinkDetailView(drink: drink)
    }
    .environmentObject(store)
}
