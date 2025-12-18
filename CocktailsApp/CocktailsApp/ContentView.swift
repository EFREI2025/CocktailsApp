//
//  ContentView.swift
//  CocktailsApp
//
//  Created by imac13 on 17/12/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
                .padding()
                .task {
                    do {
                        let service = CocktailService()
                        let drinks = try await service.fetchDrinks()
                        print("✅ Nombre de cocktails :", drinks.count)
                        print("🍸 Premier cocktail :", drinks.first?.strDrink ?? "aucun")
                    } catch {
                        print("❌ Erreur :", error)
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
