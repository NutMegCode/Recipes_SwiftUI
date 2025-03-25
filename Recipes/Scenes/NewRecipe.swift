//
//  NewRecipe.swift
//  Recipes
//
//  Created by Meg on 24/3/2025.
//

import SwiftUI

struct NewRecipeView: View {
    
    @Binding var recipeList: [Recipe]
    
    // State variables to store user input
    @State private var recipeName: String = ""
    @State private var description: String = ""
    @State private var serves: String = ""
    @State private var qty: String = ""
    @State private var ingredients: String = ""
    @State private var method: String = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var isFavorite: Bool = false
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            HStack {
                
                Spacer().frame(maxWidth: .infinity)

                Text("New Recipe")
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .frame(maxWidth: .infinity)

                Button(action: {
                    isFavorite.toggle()
                }) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .font(.system(size: 35, weight: .regular, design: .default))
                        .tint(Color.yellow)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 8)
            
            
            
            TextField("Name", text: $recipeName).textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("description", text: $description).textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("serves", text: $serves).textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("qty", text: $qty).textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("ingredients", text: $ingredients).textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("method", text: $method).textFieldStyle(RoundedBorderTextFieldStyle())
            
            Spacer()
            
            Button("Save", action: {
                
                recipeList.append(Recipe(name: recipeName,
                                      serves: Double(serves) ?? 0,
                                      description: description,
                                      method: method,
                                         isFavourite: isFavorite))
                
                RecipeStorage().saveRecipes(recipeList)
                
                presentationMode.wrappedValue.dismiss()
            })
            
        }.padding(20)
    }
}

#Preview {
    
    @Previewable @State var recipeList = [] as [Recipe]
    
    NewRecipeView(recipeList: $recipeList)
}
