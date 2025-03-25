//
//  ContentView.swift
//  Recipes
//
//  Created by Meg on 24/3/2025.
//

import SwiftUI

struct Dashboard: View {
    
//    let recipeList = [Recipe(name: "Chicken", isFavourite: true), Recipe(name: "Beef", isFavourite: false)]
    
    @State var recipeList = RecipeStorage().loadRecipes()
    @State var favourites = FavouritesStorage().loadFavourites()
    
    @State var filtered = false
    
    var body: some View {
        
        NavigationView {
            VStack {
                // Custom Title Bar
                HStack {
                    Button(action: {
                        filtered.toggle()
                    }) {
                        Image(systemName: filtered ? "star.fill" : "star")
                            .font(.system(size: 35, weight: .regular, design: .default))
                            .tint(Color.yellow)
                    }
                    .frame(maxWidth: .infinity)

                    Text("Recipe")
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .frame(maxWidth: .infinity)

                    NavigationLink(destination: NewRecipeView(recipeList: $recipeList)) {
                        Image(systemName: "plus")
                            .font(.system(size: 35, weight: .bold, design: .default))
                            .tint(Color.cyan)


                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 8)
                
                @State var myList = filtered ? recipeList.filter { $0.isFavourite } : recipeList
                
                List {
                    ForEach($myList) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipeList: $recipeList, favourites: $favourites, recipe: recipe)) {
                            RecipeCell(recipe: recipe)
                        }
// Navigation link is reccomended as the default method to manage this but there is not a non hacky way to remove the arrow on these navigation rows, the api support just isn't there for custom styling of this yet
                    }
                }
            }
        }
    }
}

#Preview {
    Dashboard()
}


