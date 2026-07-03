//
//  Dashboard.swift
//  Recipes
//
//  Created by Meg on 24/3/2025.
//

import SwiftUI
import UniformTypeIdentifiers

// Navigation routes used throughout the app's NavigationStack
enum AppRoute: Hashable {
    case detail(UUID)
    case newRecipe
    case editRecipe(UUID)
}

struct Dashboard: View {

    @State private var recipeList = RecipeStorage().loadRecipes()
    @State private var favourites = FavouritesStorage().loadFavourites()
    @State private var filtered = false
    @State private var navPath = NavigationPath()
    @State private var showingImporter = false
    // Separate value-type Set so SwiftUI can diff favourite changes on class-based Recipe.
    // Recipe is a reference type — mutating recipe.isFavourite alone won't trigger cell re-renders.
    @State private var favouriteIDs: Set<UUID> = []

    private var displayedRecipes: [Recipe] {
        filtered ? recipeList.filter { favouriteIDs.contains($0.id) } : recipeList
    }

    var body: some View {
        NavigationStack(path: $navPath) {
            VStack(spacing: 0) {
                titleBar
                recipeListView
                importExportBar
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .detail(let id):
                    if let index = recipeList.firstIndex(where: { $0.id == id }) {
                        RecipeDetailView(
                            recipeList: $recipeList,
                            favourites: $favourites,
                            navPath: $navPath,
                            index: index
                        )
                    }
                case .newRecipe:
                    NewRecipeView(
                        recipeList: $recipeList,
                        favourites: $favourites,
                        navPath: $navPath,
                        editingIndex: nil
                    )
                case .editRecipe(let id):
                    if let index = recipeList.firstIndex(where: { $0.id == id }) {
                        NewRecipeView(
                            recipeList: $recipeList,
                            favourites: $favourites,
                            navPath: $navPath,
                            editingIndex: index
                        )
                    }
                }
            }
        }
        .onAppear {
            syncFavouriteIDs()
        }
        .onChange(of: navPath) {
            // Re-sync when returning from detail/edit views that may have changed isFavourite
            syncFavouriteIDs()
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [UTType.json]
        ) { result in
            guard case .success(let url) = result else { return }
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            guard let data = try? Data(contentsOf: url),
                  let imported = try? JSONDecoder().decode([Recipe].self, from: data) else { return }
            recipeList.append(contentsOf: imported)
            favourites.favourites = recipeList.filter { $0.isFavourite }
            RecipeStorage().saveRecipes(recipeList)
            FavouritesStorage().saveFavorites(favourites)
            syncFavouriteIDs()
        }
    }

    // MARK: - Subviews

    private var titleBar: some View {
        HStack {
            Button {
                filtered.toggle()
            } label: {
                Image(systemName: filtered ? "star.fill" : "star")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(filtered ? .yellow : .gray)
            }
            .frame(maxWidth: .infinity)

            Text("Recipes")
                .font(.system(size: 22, weight: .bold))
                .frame(maxWidth: .infinity)

            Button {
                navPath.append(AppRoute.newRecipe)
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.teal)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }

    @ViewBuilder
    private var recipeListView: some View {
        if displayedRecipes.isEmpty {
            Spacer()
            Text(filtered ? "No favourite recipes" : "No recipes")
                .foregroundColor(.secondary)
            Spacer()
        } else {
            List {
                ForEach(displayedRecipes, id: \.id) { recipe in
                    HStack {
                        Button {
                            navPath.append(AppRoute.detail(recipe.id))
                        } label: {
                            HStack {
                                Text(recipe.name ?? "-")
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        Button {
                            toggleFavourite(recipe)
                        } label: {
                            Image(systemName: favouriteIDs.contains(recipe.id) ? "star.fill" : "star")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(favouriteIDs.contains(recipe.id) ? .yellow : .gray)
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .onMove { from, to in
                    recipeList.move(fromOffsets: from, toOffset: to)
                    RecipeStorage().saveRecipes(recipeList)
                }
                .moveDisabled(filtered)
            }
            .environment(\.editMode, .constant(.active))
            .listStyle(.plain)
        }
    }

    private var importExportBar: some View {
        HStack {
            Button {
                showingImporter = true
            } label: {
                Label("Import", systemImage: "square.and.arrow.down")
                    .font(.system(size: 14))
            }
            .frame(maxWidth: .infinity)

            Divider().frame(height: 20)

            if let url = RecipeStorage().exportFileURL(for: recipeList) {
                ShareLink(item: url, subject: Text("My Recipes")) {
                    Label("Export", systemImage: "square.and.arrow.up")
                        .font(.system(size: 14))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(Color(.systemGroupedBackground))
        .overlay(Divider(), alignment: .top)
    }

    // MARK: - Actions

    private func toggleFavourite(_ recipe: Recipe) {
        if favouriteIDs.contains(recipe.id) {
            favourites.removeFromFavourites(recipe)
            favouriteIDs.remove(recipe.id)
        } else {
            favourites.addToFavourites(recipe)
            favouriteIDs.insert(recipe.id)
        }
        RecipeStorage().saveRecipes(recipeList)
        FavouritesStorage().saveFavorites(favourites)
    }

    private func syncFavouriteIDs() {
        favouriteIDs = Set(recipeList.filter { $0.isFavourite }.map { $0.id })
    }
}

#Preview {
    Dashboard()
}
