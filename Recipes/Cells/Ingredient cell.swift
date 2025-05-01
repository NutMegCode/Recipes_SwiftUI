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
            Text(getDoubleToString(ingredient.quantity))
                .frame(width: 50)

            Spacer()

            Text(ingredient.uom ?? "")
                .frame(width: 50)

            Spacer()

            Text(ingredient.name ?? "")
                .frame(width: 70)
        }
    }
}
