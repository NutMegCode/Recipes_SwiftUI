//
//  Recipe.swift
//  Recipes
//
//  Created by Meg on 24/3/2025.
//

import SwiftUI

struct RecipeDetailView: View {
    
    @Binding var recipeList: [Recipe]
    @Binding var favourites: Favourites
    @Binding var recipe: Recipe
    
    // State variables to store user input
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var serves: String = ""
    
    var body: some View {
        
        var isFavorite: Bool = recipe.isFavourite
        
        ScrollView {
            
            VStack(alignment: .leading, spacing: 20) {
                
                HStack {
                    Button(action: {
                        
                        recipeList.removeAll{ $0.name == recipe.name }
                        
                        if recipe.isFavourite{
                            favourites.removeFromFavourites(recipe)
                            FavouritesStorage().saveFavorites(favourites)
                        }
                        
                        RecipeStorage().saveRecipes(recipeList)
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 25, weight: .regular, design: .default))
                            .tint(Color.red)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Text(recipe.name ?? "Recipe")
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
                
                VStack(alignment: .leading)  {
                    Text("description")
                    Text(recipe.description ?? "-")
                }
                
                HStack {
                    Text("serves")
                    TextField("serves", text: $serves).textFieldStyle(RoundedBorderTextFieldStyle()).frame(width: 100).padding(8)
                    Button(action: {
                        
                        let ingredientsList = recipe.ingredients
                        let servesDouble = Double(serves) ?? 0.00
                        let floatServes = Float(serves) ?? 0.00
                        
                        let decimalServes = Decimal(servesDouble)
                        
                        for ingredient in ingredientsList {
                            if let quantityPerOneServe = ingredient?.quantityPerOneServe {
                                
                                //this stuff should demonstrate the different precisions of each data type. becuase Swift uses the IEEE standard there can be some imprecision with certain numbers
                                //to best demonstrate the imprecision create a recipe with 1 serve and an item with 0.1 quantity. then after saving recalculate with 0.2 serves.
                                let doubleResult = NSDecimalNumber(decimal: quantityPerOneServe).doubleValue * servesDouble
                                debugPrint("Double result   \(ingredient?.name ?? ""):\(String(format: "%.20f", doubleResult))")
                                
                                let floatResult = NSDecimalNumber(decimal: quantityPerOneServe).floatValue * floatServes
                                debugPrint("Float result    \(ingredient?.name ?? ""): \(String(format: "%.20f", floatResult))")
                                
                                let formatter = NumberFormatter()
                                formatter.numberStyle = .decimal
                                formatter.minimumFractionDigits = 20
                                formatter.maximumFractionDigits = 20
                                
                                let decimalResult = quantityPerOneServe * decimalServes
                                if let formattedDecimal = formatter.string(from: decimalResult as NSDecimalNumber) {
                                    debugPrint("Decimal result  \(ingredient?.name ?? ""): \(formattedDecimal)")
                                }
                                
                                debugPrint("==============================")
                                
                                ingredient?.quantity = doubleResult
                                
                            }
                        }
                        
                        
                    }) {
                        Image(systemName: "arrow.trianglehead.counterclockwise")
                            .font(.system(size: 20, weight: .regular, design: .default))
                            .tint(Color.cyan)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("ingredients")
                    
                    ForEach(recipe.ingredients.compactMap { $0 }) { ingredient in
                        IngredientCell(ingredient: ingredient)
                            .frame(maxHeight: CGFloat(recipe.ingredients.count) * 50)
                    }
                }
                
                VStack(alignment: .leading)  {
                    Text("method")
                    Text(recipe.method ?? "-")
                }
                
                Spacer()
                

                
            }.padding(20)
                .onAppear {
                    // Initialize the `serves` state when the view appears
                    serves = getDoubleToString(recipe.serves)
                }
        }
        
        Button(action: {

            
        }){
            Text("Save")
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.teal)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding(.horizontal, 8)
    }
    
}

#Preview {
    
    @Previewable @State var recipeList = [] as [Recipe]
    @Previewable @State var favourites = Favourites()
    @Previewable @State var recipe = Recipe()

    
    RecipeDetailView(recipeList: $recipeList, favourites: $favourites, recipe: $recipe)
}

