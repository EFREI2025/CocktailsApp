import SwiftUI

struct DrinkDetailView: View {
    let drink: Drink

    private var instructionsToShow: String? {
        // Priorité FR, sinon EN
        if let fr = drink.strInstructionsFR, !fr.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return fr
        }
        if let en = drink.strInstructions, !en.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return en
        }
        return nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // --- ZONE IMAGE ---
                if let urlString = drink.strDrinkThumb,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Rectangle().fill(Color.gray.opacity(0.1)).frame(height: 350)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                        case .failure:
                            Rectangle().fill(Color.gray.opacity(0.1)).frame(height: 350)
                                .overlay(Image(systemName: "photo.slash"))
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Rectangle().fill(Color.gray.opacity(0.1)).frame(height: 300)
                }

                // --- ZONE CONTENU ---
                VStack(alignment: .leading, spacing: 20) {

                    // En-tête : Catégorie + Badge alcoolisé
                    HStack {
                        if let category = drink.strCategory {
                            Text(category.uppercased())
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        // Badge Alcoholic / Non alcoholic
                        let alcoholic = drink.strAlcoholic ?? "—"
                        Label(alcoholic, systemImage: "wineglass")
                            .font(.caption).fontWeight(.semibold)
                            .foregroundColor(alcoholic.lowercased().contains("non") ? .blue : .orange)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background((alcoholic.lowercased().contains("non") ? Color.blue : Color.orange).opacity(0.1))
                            .cornerRadius(8)
                    }

                    // Titre
                    Text(drink.strDrink)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

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
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                        }
                    } else {
                        Text("Aucune instruction disponible.")
                            .foregroundColor(.secondary)
                    }

                    // Ingrédients
                    Divider()

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
                                    if let m = line.measure, !m.isEmpty {
                                        Text(m)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .font(.subheadline)
                            }
                        }
                    }

                    Spacer(minLength: 30)

                    // Bouton Favori (plus tard -> SwiftData)
                    Button(action: {
                        // TODO: favoris
                    }) {
                        Text("Ajouter aux favoris")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
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
