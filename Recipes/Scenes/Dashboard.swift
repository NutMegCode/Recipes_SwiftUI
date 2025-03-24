//
//  ContentView.swift
//  Recipes
//
//  Created by Meg on 24/3/2025.
//

import SwiftUI

struct Dashboard: View {
    
    let recipeList = [Recipe(name: "Chicken", isFavourite: true), Recipe(name: "Beef", isFavourite: false)]
    
    
    var body: some View {
        NavigationView {
            
            List {
                ForEach(recipeList) { recipe in
                    NavigationLink(destination: SecondView(name: recipe.name ?? "-")) {
                        RecipeCell(recipe: recipe)
                    }
                }
            }
            .navigationTitle("Recipe")
            navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    Dashboard()
}


