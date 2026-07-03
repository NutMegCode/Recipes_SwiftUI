//
//  Recipe cell.swift
//  Recipes
//
//  Created by Meg on 24/3/2025.
//

import SwiftUI

struct RecipeCell: View {
    var recipe: Recipe
    var isFavourite: Bool          // value type — gives SwiftUI something concrete to diff
    var onFavouriteTapped: () -> Void

    var body: some View {
        HStack {
            Text(recipe.name ?? "-")
                .foregroundColor(.primary)
            Spacer()
            Button(action: onFavouriteTapped) {
                Image(systemName: isFavourite ? "star.fill" : "star")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isFavourite ? .yellow : .gray)
            }
            .buttonStyle(.borderless)
        }
    }
}
