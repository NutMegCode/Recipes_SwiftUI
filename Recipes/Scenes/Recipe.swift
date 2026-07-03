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
    @Binding var navPath: NavigationPath
    let index: Int

    @Environment(\.dismiss) private var dismiss

    @State private var serves: String = ""
    @State private var isFavourite: Bool = false
    @State private var showDeleteConfirm = false

    // Guard against brief re-render after deletion
    private var recipe: Recipe {
        guard index < recipeList.count else { return Recipe() }
        return recipeList[index]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Description
                if let desc = recipe.description, !desc.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Description")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        Text(desc)
                    }
                }

                // Serves + recalculate + save
                HStack(spacing: 12) {
                    Text("Serves")
                    TextField("Serves", text: $serves)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .frame(width: 80)
                    Button {
                        recalculate()
                    } label: {
                        Image(systemName: "arrow.trianglehead.counterclockwise")
                            .foregroundColor(.teal)
                    }
                    Button {
                        save()
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundColor(.teal)
                    }
                }

                // Ingredients
                if !recipe.ingredients.compactMap({ $0 }).isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ingredients")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        ForEach(recipe.ingredients.compactMap { $0 }, id: \.id) { ingredient in
                            IngredientCell(ingredient: ingredient)
                            Divider()
                        }
                    }
                }

                // Tools
                if !recipe.tools.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tools")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        ForEach(recipe.tools.indices, id: \.self) { i in
                            Text(recipe.tools[i])
                            Divider()
                        }
                    }
                }

                // Method
                if !recipe.method.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Method")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        ForEach(recipe.method.indices, id: \.self) { i in
                            HStack(alignment: .top, spacing: 10) {
                                Text("\(i + 1).")
                                    .foregroundColor(.secondary)
                                    .frame(width: 24, alignment: .trailing)
                                Text(recipe.method[i])
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }

                Spacer(minLength: 20)
            }
            .padding(20)
        }
        .navigationTitle(recipe.name ?? "Recipe")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // Favourite star
                Button {
                    isFavourite.toggle()
                } label: {
                    Image(systemName: isFavourite ? "star.fill" : "star")
                        .foregroundColor(isFavourite ? .yellow : .gray)
                }

                // Delete
                Button {
                    showDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }

                // Edit
                Button {
                    navPath.append(AppRoute.editRecipe(recipe.id))
                } label: {
                    Image(systemName: "pencil")
                        .foregroundColor(.teal)
                }
            }
        }
        .alert("Delete \(recipe.name ?? "this recipe")?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { deleteRecipe() }
        } message: {
            Text("This cannot be undone.")
        }
        .onAppear {
            serves = getDoubleToString(recipe.serves)
            isFavourite = recipe.isFavourite
        }
    }

    // MARK: - Actions

    private func recalculate() {
        guard let newServes = Double(serves) else { return }
        let decimalServes = Decimal(newServes)
        for ingredient in recipe.ingredients {
            if let q = ingredient?.quantityPerOneServe {
                let doubleResult = NSDecimalNumber(decimal: q).doubleValue * newServes
                debugPrint("Double result   \(ingredient?.name ?? ""): \(String(format: "%.20f", doubleResult))")
                let decimalResult = q * decimalServes
                debugPrint("Decimal result  \(ingredient?.name ?? ""): \(decimalResult)")
                ingredient?.quantity = doubleResult
            }
        }
        recipeList = recipeList // trigger re-render
    }

    private func save() {
        let originalFavourite = recipe.isFavourite
        if originalFavourite != isFavourite {
            if isFavourite {
                favourites.addToFavourites(recipe)
            } else {
                favourites.removeFromFavourites(recipe)
            }
        }
        recipe.serves = Double(serves)
        RecipeStorage().saveRecipes(recipeList)
        FavouritesStorage().saveFavorites(favourites)
        dismiss()
    }

    private func deleteRecipe() {
        let toDelete = recipe
        if toDelete.isFavourite { favourites.removeFromFavourites(toDelete) }
        recipeList.remove(at: index)
        RecipeStorage().saveRecipes(recipeList)
        FavouritesStorage().saveFavorites(favourites)
        dismiss()
    }
}

#Preview {
    @Previewable @State var recipeList = [Recipe(name: "Test", serves: 4, description: "A test", tools: ["Pan"], method: ["Step one", "Step two"])]
    @Previewable @State var favourites = Favourites()
    @Previewable @State var navPath = NavigationPath()

    NavigationStack {
        RecipeDetailView(recipeList: $recipeList, favourites: $favourites, navPath: $navPath, index: 0)
    }
}
