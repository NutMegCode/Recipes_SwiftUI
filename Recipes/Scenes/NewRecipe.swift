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
    @State private var method: String = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var isFavorite: Bool = false
    
    //holding state is quite tedious with extra models that seem repeated code
    @State private var ingredientModels: [NewIngredientModel] = []
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            HStack {
                
                LabeledContent("Name") {
                    TextField("", text: $recipeName).textFieldStyle(RoundedBorderTextFieldStyle())
                }

                Button(action: {
                    isFavorite.toggle()
                }) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .font(.system(size: 35, weight: .regular, design: .default))
                        .tint(Color.yellow)
                }
                
            }
            .padding(.vertical, 8)
            
            
            VStack(alignment: .leading) {
                Text("description")
                    .font(.headline)

                TextEditor(text: $description)
                    .frame(height: 90)
                    .border(Color.gray.opacity(0.5))
                    .padding(.top, 4)
            }
            .padding()

            LabeledContent("serves") {
                TextField("", text: $serves).textFieldStyle(RoundedBorderTextFieldStyle())
            }
            

            VStack(alignment: .leading) {
                HStack{
                    Spacer().frame(maxWidth: .infinity)
                    
                    Text("Ingredients")
                    Button(action: {
                        ingredientModels.append(NewIngredientModel())                    }) {
                            Image(systemName: "plus.square")
                                .font(.system(size: 20, weight: .regular, design: .default))
                                .tint(Color.teal)
                        }
                        .frame(maxWidth: .infinity)
                }
                
                List {
                    ForEach(ingredientModels.indices, id: \.self) { index in
                        NewIngredientCell(model: $ingredientModels[index])
                    }
                }
                .frame(height: CGFloat(ingredientModels.count + 1) * 50)
            }
            
            VStack(alignment: .leading) {
                Text("method")
                    .font(.headline)

                TextEditor(text: $method)
                    .frame(height: 90)
                    .border(Color.gray.opacity(0.5))
                    .padding(.top, 4)
            }
            .padding()
            
            Spacer()
            
            Button(action: {
                
                let ingredients = ingredientModels.map {
                    Ingredient(
                        name: $0.name,
                        quantity: Double($0.qty) ?? 0.0,
                        uom: $0.uom
                    )
                }
                
                //for each item in the table get its Ingredient and add to the ingredients list
                
                recipeList.append(Recipe(name: recipeName,
                                      serves: Double(serves) ?? 0,
                                      description: description,
                                         ingredients: ingredients,
                                         method: method,
                                         isFavourite: isFavorite))
                
                RecipeStorage().saveRecipes(recipeList)
                
                presentationMode.wrappedValue.dismiss()
            }){
                Text("Save")
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.teal)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 8)
            
        }.padding(20)
    }
}

//#Preview {
//    
//    @Previewable @State var recipeList = [] as [Recipe]
//    
//    NewRecipeView(recipeList: $recipeList)
//}
