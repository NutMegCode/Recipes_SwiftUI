//
//  Ingredient cell.swift
//  Recipes
//
//  Created by Meg on 24/3/2025.
//

import SwiftUI

struct IngredientCell: View {
    var ingredient: Ingredient

    var body: some View {
        HStack(spacing: 8) {
            Text(getDoubleToString(ingredient.quantity))
                .frame(width: 50, alignment: .leading)
            Text(ingredient.uom ?? "")
                .frame(width: 60, alignment: .leading)
                .foregroundColor(.secondary)
            Text(ingredient.name ?? "")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.system(size: 15))
    }
}
