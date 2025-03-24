//
//  Recipe.swift
//  Recipes
//
//  Created by Meg on 24/3/2025.
//

import SwiftUI

struct RecipeCell: View {
    let recipe: Recipe

    var body: some View {
        HStack {
            Text(recipe.name ?? "-")
            Spacer()
            Image(systemName: recipe.isFavourite ? "star.fill" : "star")
        }
    }
}
