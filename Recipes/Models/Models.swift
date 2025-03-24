//
//  Untitled.swift
//  Recipes
//
//  Created by Meg on 17/3/2025.
//

import Foundation

class Recipe: Codable, Identifiable {
    var name: String?
    var serves: Double?
    var description: String?
    var ingredients: [Ingredient?] // Removed optional type inside array
    var method: String?
    var isFavourite: Bool

    init(name: String? = nil, serves: Double? = nil, description: String? = nil, ingredients: [Ingredient] = [], method: String? = nil, isFavourite: Bool = false) {
        self.name = name
        self.serves = serves
        self.description = description
        self.ingredients = ingredients
        self.method = method
        self.isFavourite = isFavourite
    }
}


class Ingredient: Codable {
    var name: String?
    var quantity: Double?
    var uom: String?
    var quantityPerOneServe: Decimal?

    init(name: String? = nil, quantity: Double? = nil, uom: String? = nil, quantityPerOneServe: Decimal? = nil) {
        self.name = name
        self.quantity = quantity
        self.uom = uom
        self.quantityPerOneServe = quantityPerOneServe
    }
    
    func getQuantityOfOneForServes(_ serves: Decimal?) -> Decimal {
        return Decimal((quantity ?? 0)) / (serves ?? 1) // Avoid division by zero
    }

    enum CodingKeys: String, CodingKey {
        case name, quantity, uom, quantityPerOneServe
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        quantity = try container.decodeIfPresent(Double.self, forKey: .quantity)
        uom = try container.decodeIfPresent(String.self, forKey: .uom)
        if let decimalString = try container.decodeIfPresent(String.self, forKey: .quantityPerOneServe) {
            quantityPerOneServe = Decimal(string: decimalString)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(quantity, forKey: .quantity)
        try container.encodeIfPresent(uom, forKey: .uom)
        if let quantityPerOneServe = quantityPerOneServe {
            try container.encode("\(quantityPerOneServe)", forKey: .quantityPerOneServe) // Store Decimal as String
        }
    }
}

class Favourites: Codable {
    var favourites: [Recipe] = []
    
    // A closure to notify when a recipe is favorited (leaks memory!)
    var onFavouriteUpdate: (() -> Void)?
    
    deinit {
        debugPrint("Favourites deinitialized")
    }

    func addToFavourites(_ recipe: Recipe) {
        recipe.isFavourite = true
        favourites.append(recipe)
        
        // Retain Cycle: Closure strongly captures `self`
        onFavouriteUpdate = {
            debugPrint("\(recipe.name ?? "Untitled") was added to favorites!")
            debugPrint("Total favorites: \(self.favourites.count)") // Strong reference to `self` if you comment out the this line and line 101 the deinit should happen
        }
        
        onFavouriteUpdate?()
    }
    
    func removeFromFavourites(_ recipe: Recipe) {
        recipe.isFavourite = false
        favourites.removeAll(where: {$0.name == recipe.name}) //okay we realy need some unique identifiers here...
        
        // Retain Cycle: Closure strongly captures `self`
        onFavouriteUpdate = {
            debugPrint("\(recipe.name ?? "Untitled") was removed from favorites!")
            debugPrint("Total favorites: \(self.favourites.count)") // Strong reference to `self` if you comment out the this line and line 88 the deinit should happen
        }
        
        onFavouriteUpdate?()
    }
    

    init() {}

    // MARK: - Codable Conformance
    enum CodingKeys: String, CodingKey {
        case favourites
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        favourites = try container.decodeIfPresent([Recipe].self, forKey: .favourites) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(favourites, forKey: .favourites)
    }
}
