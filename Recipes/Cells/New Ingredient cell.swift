//
//  New Ingredient.swift
//  Recipes
//
//  Created by Meg on 24/3/2025.
//

import SwiftUI

struct NewIngredientModel {
    var qty: String = ""
    var uom: String = ""
    var name: String = ""
}

struct NewIngredientCell: View {
    @Binding var model: NewIngredientModel

    var body: some View {
        HStack {
            TextField("QTY", text: $model.qty)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 50)

            Spacer()

            TextField("UOM", text: $model.uom)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 70)

            Spacer()

            TextField("Title", text: $model.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }

    func getIngredient() -> Ingredient {
        Ingredient(
            name: model.name,
            quantity: Double(model.qty) ?? 0.0,
            uom: model.uom
        )
    }
}
