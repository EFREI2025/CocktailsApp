//
//  Cocktail.swift
//  CocktailsApp
//
//  Created by Georgy GUEI on 12/17/25.
//

import Foundation

// MARK: - API Wrapper
struct DrinkResponse: Codable {
    let drinks: [Drink]?
}

// MARK: - Drink (CocktailDB full model)
struct Drink: Codable, Identifiable {
    // Identifiable
    var id: String { idDrink }

    // 1) Identity
    let idDrink: String

    // 2) Name & variants
    let strDrink: String
    let strDrinkAlternate: String?

    // 3) Tags & media
    let strTags: String?
    let strVideo: String?

    // 4) Classification
    let strCategory: String?
    let strIBA: String?
    let strAlcoholic: String?
    let strGlass: String?

    // 5) Instructions (multilingual)
    let strInstructions: String?
    let strInstructionsES: String?
    let strInstructionsDE: String?
    let strInstructionsFR: String?
    let strInstructionsIT: String?
    let strInstructionsZH_HANS: String?
    let strInstructionsZH_HANT: String?

    // 6) Main image
    let strDrinkThumb: String?

    // 7) Ingredients (1..15)
    let strIngredient1: String?
    let strIngredient2: String?
    let strIngredient3: String?
    let strIngredient4: String?
    let strIngredient5: String?
    let strIngredient6: String?
    let strIngredient7: String?
    let strIngredient8: String?
    let strIngredient9: String?
    let strIngredient10: String?
    let strIngredient11: String?
    let strIngredient12: String?
    let strIngredient13: String?
    let strIngredient14: String?
    let strIngredient15: String?

    // 8) Measures (1..15)
    let strMeasure1: String?
    let strMeasure2: String?
    let strMeasure3: String?
    let strMeasure4: String?
    let strMeasure5: String?
    let strMeasure6: String?
    let strMeasure7: String?
    let strMeasure8: String?
    let strMeasure9: String?
    let strMeasure10: String?
    let strMeasure11: String?
    let strMeasure12: String?
    let strMeasure13: String?
    let strMeasure14: String?
    let strMeasure15: String?

    // 9) Sources & rights
    let strImageSource: String?
    let strImageAttribution: String?
    let strCreativeCommonsConfirmed: String?

    // 10) Last modified
    let dateModified: String?

    // MARK: - CodingKeys (for keys with '-')
    enum CodingKeys: String, CodingKey {
        case idDrink
        case strDrink
        case strDrinkAlternate
        case strTags
        case strVideo
        case strCategory
        case strIBA
        case strAlcoholic
        case strGlass
        case strInstructions
        case strInstructionsES
        case strInstructionsDE
        case strInstructionsFR
        case strInstructionsIT
        case strInstructionsZH_HANS = "strInstructionsZH-HANS"
        case strInstructionsZH_HANT = "strInstructionsZH-HANT"
        case strDrinkThumb
        case strIngredient1
        case strIngredient2
        case strIngredient3
        case strIngredient4
        case strIngredient5
        case strIngredient6
        case strIngredient7
        case strIngredient8
        case strIngredient9
        case strIngredient10
        case strIngredient11
        case strIngredient12
        case strIngredient13
        case strIngredient14
        case strIngredient15
        case strMeasure1
        case strMeasure2
        case strMeasure3
        case strMeasure4
        case strMeasure5
        case strMeasure6
        case strMeasure7
        case strMeasure8
        case strMeasure9
        case strMeasure10
        case strMeasure11
        case strMeasure12
        case strMeasure13
        case strMeasure14
        case strMeasure15
        case strImageSource
        case strImageAttribution
        case strCreativeCommonsConfirmed
        case dateModified
    }
}

// ✅ IMPORTANT: Hashable/Equatable UNIQUEMENT basé sur idDrink (évite le “pop” auto)
extension Drink: Hashable {
    static func == (lhs: Drink, rhs: Drink) -> Bool {
        lhs.idDrink == rhs.idDrink
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(idDrink)
    }
}

// MARK: - Ingredient helper
struct IngredientLine: Hashable {
    let name: String
    let measure: String?
}

extension Drink {
    var ingredientLines: [IngredientLine] {
        let ingredients: [String?] = [
            strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5,
            strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10,
            strIngredient11, strIngredient12, strIngredient13, strIngredient14, strIngredient15
        ]

        let measures: [String?] = [
            strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5,
            strMeasure6, strMeasure7, strMeasure8, strMeasure9, strMeasure10,
            strMeasure11, strMeasure12, strMeasure13, strMeasure14, strMeasure15
        ]

        return zip(ingredients, measures)
            .compactMap { ing, meas in
                guard let ing = ing?.trimmingCharacters(in: .whitespacesAndNewlines),
                      !ing.isEmpty else { return nil }

                let cleanedMeasure = meas?.trimmingCharacters(in: .whitespacesAndNewlines)

                return IngredientLine(
                    name: ing,
                    measure: (cleanedMeasure?.isEmpty == false) ? cleanedMeasure : nil
                )
            }
    }
}
