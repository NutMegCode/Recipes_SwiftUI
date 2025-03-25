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
                    
                }) {
                    Image(systemName: "arrow.trianglehead.counterclockwise")
                        .font(.system(size: 20, weight: .regular, design: .default))
                        .tint(Color.cyan)
                }
            }
            
            VStack(alignment: .leading) {
                Text("ingredients")
                List {
                    ForEach(recipe.ingredients.compactMap { $0 }) { ingredient in
                        IngredientCell(ingredient: ingredient)
                    }.frame(maxHeight: CGFloat(recipe.ingredients.count) * 50)
                }
            }.frame(height: CGFloat(recipe.ingredients.count + 1) * 50)
            
            VStack(alignment: .leading)  {
                Text("method")
                Text(recipe.method ?? "-")
            }

            Spacer()
            
            Button("Save", action: {

            })
            
        }.padding(20)
            .onAppear {
                // Initialize the `serves` state when the view appears
                serves = getDoubleToString(recipe.serves)
            }
    }

}

#Preview {
    
    @Previewable @State var recipeList = [] as [Recipe]
    @Previewable @State var favourites = Favourites()
    @Previewable @State var recipe = Recipe()

    
    RecipeDetailView(recipeList: $recipeList, favourites: $favourites, recipe: $recipe)
}

