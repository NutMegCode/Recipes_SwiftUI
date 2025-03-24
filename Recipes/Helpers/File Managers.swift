//
//  File Managers.swift
//  Recipes
//
//  Created by Meg on 20/3/2025.
//

//we can manage local storage files without needing to import anything beyond Foundation and UIKit!!
import Foundation
import UIKit

class FavouritesStorage {
    private let fileName = "MyRecipes_favorites.json"

    func saveFavorites(_ favorites: Favourites?) {
        
        if let favorites = favorites {
            
            let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
            do {
                let data = try JSONEncoder().encode(favorites)
                try data.write(to: fileURL)
            } catch {
                debugPrint("Error saving favorites: \(error)")
            }
        }
    }

    func loadFavourites() -> Favourites {
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            let emptyFavorites = Favourites()
            saveFavorites(emptyFavorites) // Create an empty file
            return emptyFavorites
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(Favourites.self, from: data)
        } catch {
            debugPrint("Error loading favorites: \(error)")
            return Favourites()
        }
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}

class RecipeStorage {
    private let fileName = "MyRecipes_recipes.json"

    func saveRecipes(_ recipes: [Recipe]) {
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            let data = try JSONEncoder().encode(recipes)
            try data.write(to: fileURL)
        } catch {
            debugPrint("Error saving recipes: \(error)")
        }
    }

    func loadRecipes() -> [Recipe] {
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            let emptyRecipes: [Recipe] = []
            saveRecipes(emptyRecipes) // Create an empty file
            return emptyRecipes
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([Recipe].self, from: data)
        } catch {
            debugPrint("Error loading recipes: \(error)")
            return []
        }
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}

class RecipeExporter {
    
    func exportRecipes(_ recipes: [Recipe], from viewController: UIViewController) {
        let fileURL = getDocumentsDirectory().appendingPathComponent("ExportedRecipes.json")
        
        // a little error handling here
        do {
            let data = try JSONEncoder().encode(recipes)
            try data.write(to: fileURL)
            
            // Open share sheet so user can save the file somewhere accessible
            let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            viewController.present(activityVC, animated: true)
            
        } catch {
            debugPrint("Error exporting recipes: \(error)")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}


class RecipeImporter: NSObject, UINavigationControllerDelegate {
    
    var onRecipesImported: (([Recipe]) -> Void)?
    
    func importRecipes(from viewController: UIViewController) {
        
        //you've gotta have iOS 14 or later for this, it is not backwards compatible and doesn't enforce checking for compatibility
        
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.json], asCopy: true)
        documentPicker.delegate = self
        viewController.present(documentPicker, animated: true)
    }
}

extension RecipeImporter: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileURL = urls.first else {
            debugPrint("No file selected")
            return
        }
            // a little error handling here
            do {
                let data = try Data(contentsOf: fileURL)
                let importedRecipes = try JSONDecoder().decode([Recipe].self, from: data)
                onRecipesImported?(importedRecipes)
            } catch {
                debugPrint("Error importing recipes: \(error)")
            }

    }
}
