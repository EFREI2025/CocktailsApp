import SwiftUI

struct DrinkRowView: View {
    let drink: Drink

    var body: some View {
        HStack(spacing: 12) {
            if let urlString = drink.strDrinkThumb,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "photo")
                    .frame(width: 60, height: 60)
                    .background(.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(drink.strDrink)
                    .font(.headline)

                Text(drink.strCategory ?? "Sans catégorie")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(drink.strGlass ?? "Verre inconnu")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Petit “badge” comme ton stock/rupture
            Text(drink.strAlcoholic ?? "—")
                .font(.caption)
                .padding(6)
                .background((drink.strAlcoholic ?? "").lowercased().contains("non") ? Color.blue.opacity(0.2) : Color.orange.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}
