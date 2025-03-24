//
//  Recipe.swift
//  Recipes
//
//  Created by Meg on 24/3/2025.
//

import SwiftUI

struct SecondView: View {
    var name: String

    var body: some View {
        Text("You chose \(name)")
    }
}

#Preview {
    SecondView(name: "example")
}
