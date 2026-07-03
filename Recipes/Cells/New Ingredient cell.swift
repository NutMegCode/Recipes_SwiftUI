//
//  New Ingredient cell.swift
//  Recipes
//
//  Created by Meg on 24/3/2025.
//

import SwiftUI

struct NewIngredientModel {
    var qty: String = ""
    var uom: String = ""
    var name: String = ""

    init() {}

    init(from ingredient: Ingredient) {
        qty = getDoubleToString(ingredient.quantity)
        uom = ingredient.uom ?? ""
        name = ingredient.name ?? ""
    }

    var isEmpty: Bool { qty.isEmpty && uom.isEmpty && name.isEmpty }
}

struct NewIngredientCell: View {
    @Binding var model: NewIngredientModel
    var focused: FocusState<RecipeFormFocus?>.Binding
    var index: Int

    var body: some View {
        HStack(spacing: 8) {
            TextField("Qty", text: $model.qty)
                .keyboardType(.decimalPad)
                .frame(width: 55)
                .focused(focused, equals: .ingredient(index))
            TextField("Unit", text: $model.uom)
                .frame(width: 65)
            TextField("Ingredient", text: $model.name)
        }
        .textFieldStyle(.roundedBorder)
    }
}
