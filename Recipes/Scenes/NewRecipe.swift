//
//  NewRecipe.swift
//  Recipes
//
//  Created by Meg on 24/3/2025.
//

import SwiftUI

// Shared across NewRecipeView, NewIngredientCell, and NewToolCell
enum RecipeFormFocus: Hashable {
    case ingredient(Int)
    case tool(Int)
    case method(Int)
}

struct NewRecipeView: View {

    @Binding var recipeList: [Recipe]
    @Binding var favourites: Favourites
    @Binding var navPath: NavigationPath
    let editingIndex: Int?

    @Environment(\.dismiss) private var dismiss

    @State private var recipeName: String = ""
    @State private var serves: String = ""
    @State private var description: String = ""
    @State private var isFavourite: Bool = false
    @State private var ingredientModels: [NewIngredientModel] = [NewIngredientModel()]
    @State private var toolModels: [String] = [""]
    @State private var methodSteps: [String] = [""]
    // Track which recipe was last pre-populated — guards against SwiftUI reusing views across navigation
    @State private var prepopulatedForRecipeID: UUID? = nil
    @FocusState private var focusedField: RecipeFormFocus?

    private var isEditMode: Bool { editingIndex != nil }

    // MARK: - Focus helpers for keyboard toolbar conditionals

    private var isIngredientFocused: Bool {
        if case .ingredient = focusedField { return true }
        return false
    }
    private var isToolFocused: Bool {
        if case .tool = focusedField { return true }
        return false
    }
    private var isMethodFocused: Bool {
        if case .method = focusedField { return true }
        return false
    }

    var body: some View {
        // Form (not List) for data entry — avoids TextEditor focus stealing
        // and any List-internal gesture interference with keyboard.
        Form {
            // Recipe basics
            Section {
                TextField("Recipe name", text: $recipeName)
                    .submitLabel(.next)
                HStack {
                    Text("Serves")
                    Spacer()
                    TextField("e.g. 4", text: $serves)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                // axis: .vertical expands inline as text grows — no ZStack overlay to intercept taps
                TextField("Description", text: $description, axis: .vertical)
                    .lineLimit(3...6)
                HStack {
                    Text("Favourite")
                    Spacer()
                    Button {
                        isFavourite.toggle()
                        if isEditMode { autoSaveFavourite() }
                    } label: {
                        Image(systemName: isFavourite ? "star.fill" : "star")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(isFavourite ? .yellow : .gray)
                    }
                    .buttonStyle(.borderless)
                }
            }

            // Ingredients
            Section("Ingredients") {
                ForEach(ingredientModels.indices, id: \.self) { i in
                    NewIngredientCell(
                        model: $ingredientModels[i],
                        focused: $focusedField,
                        index: i
                    )
                }
                Button { addIngredient() } label: {
                    Label("Add another ingredient", systemImage: "plus.circle.fill")
                        .foregroundColor(.teal)
                }
            }

            // Tools
            Section("Tools") {
                ForEach(toolModels.indices, id: \.self) { i in
                    NewToolCell(
                        text: Binding(get: { toolModels[i] }, set: { toolModels[i] = $0 }),
                        focused: $focusedField,
                        index: i
                    )
                }
                Button { addTool() } label: {
                    Label("Add another tool", systemImage: "plus.circle.fill")
                        .foregroundColor(.teal)
                }
            }

            // Method — step number top-aligned so it sits on the same line as the text entry
            Section("Method") {
                ForEach(methodSteps.indices, id: \.self) { i in
                    HStack(spacing: 10) {
                        Text("\(i + 1).")
                            .foregroundColor(.secondary)
                            .frame(width: 28, alignment: .trailing)
                        TextField("Step \(i + 1)", text: Binding(
                            get: { methodSteps[i] },
                            set: { methodSteps[i] = $0 }
                        ), axis: .vertical)
                        .lineLimit(1...)
                        .focused($focusedField, equals: .method(i))
                        Menu {
                            Button {
                                guard i > 0 else { return }
                                methodSteps.swapAt(i, i - 1)
                            } label: { Label("Move Up", systemImage: "arrow.up") }
                            .disabled(i == 0)
                            Button {
                                guard i < methodSteps.count - 1 else { return }
                                methodSteps.swapAt(i, i + 1)
                            } label: { Label("Move Down", systemImage: "arrow.down") }
                            .disabled(i == methodSteps.count - 1)
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                        .buttonStyle(.borderless)
                    }
                }
                Button { addMethodStep() } label: {
                    Label("Add another step", systemImage: "plus.circle.fill")
                        .foregroundColor(.teal)
                }
            }
        }
        .navigationTitle(isEditMode ? "Edit Recipe" : "New Recipe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") { save() }
                    .tint(.teal)
            }
            // Context-sensitive Add button sits above the keyboard — mirrors the UIKit inputAccessoryView pattern
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                if isIngredientFocused {
                    Button { addIngredient() } label: {
                        Label("Add ingredient", systemImage: "plus.circle.fill")
                    }
                    .tint(.teal)
                } else if isToolFocused {
                    Button { addTool() } label: {
                        Label("Add tool", systemImage: "plus.circle.fill")
                    }
                    .tint(.teal)
                } else if isMethodFocused {
                    Button { addMethodStep() } label: {
                        Label("Add step", systemImage: "plus.circle.fill")
                    }
                    .tint(.teal)
                }
            }
        }
        .onAppear {
            let targetID = editingIndex.flatMap { $0 < recipeList.count ? recipeList[$0].id : nil }
            // Skip if we already pre-populated for this exact recipe (prevents wiping user edits on re-appear)
            guard targetID != prepopulatedForRecipeID else { return }
            prepopulatedForRecipeID = targetID
            if let idx = editingIndex, idx < recipeList.count {
                prepopulate(from: recipeList[idx])
            }
        }
    }

    // MARK: - Add row helpers (also focus the new row so Form scrolls it above the keyboard)

    private func addIngredient() {
        ingredientModels.append(NewIngredientModel())
        let idx = ingredientModels.count - 1
        DispatchQueue.main.async { focusedField = .ingredient(idx) }
    }

    private func addTool() {
        toolModels.append("")
        let idx = toolModels.count - 1
        DispatchQueue.main.async { focusedField = .tool(idx) }
    }

    private func addMethodStep() {
        methodSteps.append("")
        let idx = methodSteps.count - 1
        DispatchQueue.main.async { focusedField = .method(idx) }
    }

    // MARK: - Helpers

    private func prepopulate(from existing: Recipe) {
        recipeName = existing.name ?? ""
        serves = getDoubleToString(existing.serves)
        description = existing.description ?? ""
        isFavourite = existing.isFavourite

        let loaded = existing.ingredients.compactMap { $0 }.map { NewIngredientModel(from: $0) }
        // Always append one blank row so there is always an empty field ready to fill
        ingredientModels = loaded + [NewIngredientModel()]

        toolModels = existing.tools + [""]

        methodSteps = existing.method.isEmpty ? [""] : existing.method + [""]
    }

    private func save() {
        let recipe = isEditMode ? recipeList[editingIndex!] : Recipe()

        recipe.name = recipeName.trimmingCharacters(in: .whitespaces)
        recipe.description = description.trimmingCharacters(in: .whitespaces)
        recipe.serves = Double(serves.trimmingCharacters(in: .whitespaces))

        recipe.ingredients = ingredientModels.compactMap { model in
            guard !model.isEmpty else { return nil }
            let qty = Double(model.qty.trimmingCharacters(in: .whitespaces))
            let ingredient = Ingredient(
                name: model.name.trimmingCharacters(in: .whitespaces),
                quantity: qty,
                uom: model.uom.trimmingCharacters(in: .whitespaces)
            )
            if let q = qty, let s = recipe.serves, s > 0 {
                ingredient.quantityPerOneServe = Decimal(q) / Decimal(s)
            }
            return ingredient
        }

        recipe.tools = toolModels.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        recipe.method = methodSteps.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        recipe.isFavourite = isFavourite

        guard !recipe.isEmpty() else { return }

        if let idx = editingIndex {
            let old = recipeList[idx]
            if old.isFavourite { favourites.removeFromFavourites(old) }
            recipeList[idx] = recipe
        } else {
            recipeList.append(recipe)
        }

        if recipe.isFavourite { favourites.addToFavourites(recipe) }
        RecipeStorage().saveRecipes(recipeList)
        FavouritesStorage().saveFavorites(favourites)

        if isEditMode {
            navPath = NavigationPath()
        } else {
            dismiss()
        }
    }

    // Only called in edit mode — persists the favourite toggle without a full save
    private func autoSaveFavourite() {
        guard let idx = editingIndex, idx < recipeList.count else { return }
        let existing = recipeList[idx]
        if isFavourite {
            favourites.addToFavourites(existing)
        } else {
            favourites.removeFromFavourites(existing)
        }
        existing.isFavourite = isFavourite
        RecipeStorage().saveRecipes(recipeList)
        FavouritesStorage().saveFavorites(favourites)
    }
}

#Preview {
    @Previewable @State var recipeList: [Recipe] = []
    @Previewable @State var favourites = Favourites()
    @Previewable @State var navPath = NavigationPath()

    NavigationStack {
        NewRecipeView(recipeList: $recipeList, favourites: $favourites, navPath: $navPath, editingIndex: nil)
    }
}
