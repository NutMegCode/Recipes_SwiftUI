//
//  New Tool cell.swift
//  Recipes
//
//  Created by Meg on 3/7/2025.
//

import SwiftUI

struct NewToolCell: View {
    @Binding var text: String
    var focused: FocusState<RecipeFormFocus?>.Binding
    var index: Int

    var body: some View {
        TextField("Tool", text: $text)
            .focused(focused, equals: .tool(index))
    }
}
