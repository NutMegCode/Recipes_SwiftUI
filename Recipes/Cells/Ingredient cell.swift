//
//  Ingredient.swift
//  Recipes
//
//  Created by Meg on 24/3/2025.
//

import SwiftUI

struct IngredientCell: View {
    var ingredient: Ingredient

    var body: some View {
        HStack {
            Text(ingredient.name ?? "-")
            Spacer()
        }
    }
}
