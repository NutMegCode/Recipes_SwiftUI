//
//  File Managers.swift
//  Recipes
//
//  Created by Meg on 20/3/2025.
//

import Foundation

class FavouritesStorage {
    private let fileName = "MyRecipes_favorites.json"

    func saveFavorites(_ favorites: Favourites?) {
        guard let favorites else { return }
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        do {
            try JSONEncoder().encode(favorites).write(to: fileURL)
        } catch {
            debugPrint("Error saving favorites: \(error)")
        }
    }

    func loadFavourites() -> Favourites {
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            let empty = Favourites()
            saveFavorites(empty)
            return empty
        }
        do {
            return try JSONDecoder().decode(Favourites.self, from: Data(contentsOf: fileURL))
        } catch {
            debugPrint("Error loading favorites: \(error)")
            return Favourites()
        }
    }

    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}

class RecipeStorage {
    private let fileName = "MyRecipes_recipes.json"

    func saveRecipes(_ recipes: [Recipe]) {
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        do {
            try JSONEncoder().encode(recipes).write(to: fileURL)
        } catch {
            debugPrint("Error saving recipes: \(error)")
        }
    }

    func loadRecipes() -> [Recipe] {
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            saveRecipes([])
            return []
        }
        do {
            return try JSONDecoder().decode([Recipe].self, from: Data(contentsOf: fileURL))
        } catch {
            debugPrint("Error loading recipes: \(error)")
            return []
        }
    }

    // Writes a snapshot of recipes to a shareable export file and returns its URL
    func exportFileURL(for recipes: [Recipe]) -> URL? {
        let url = documentsDirectory.appendingPathComponent("ExportedRecipes.json")
        guard let data = try? JSONEncoder().encode(recipes) else { return nil }
        try? data.write(to: url)
        return url
    }

    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
