//
//  Models.swift
//  Recipes
//
//  Created by Meg on 17/3/2025.
//

import Foundation

class Recipe: Codable, Identifiable {
    let id: UUID
    var name: String?
    var serves: Double?
    var description: String?
    var ingredients: [Ingredient?]
    var tools: [String]
    var method: [String]
    var isFavourite: Bool

    init(name: String? = nil, serves: Double? = nil, description: String? = nil,
         ingredients: [Ingredient] = [], tools: [String] = [], method: [String] = [],
         isFavourite: Bool = false) {
        self.id = UUID()
        self.name = name
        self.serves = serves
        self.description = description
        self.ingredients = ingredients
        self.tools = tools
        self.method = method
        self.isFavourite = isFavourite
    }

    func isEmpty() -> Bool {
        (name?.isEmpty ?? true) && serves == nil && (description?.isEmpty ?? true)
            && ingredients.isEmpty && method.isEmpty
    }

    enum CodingKeys: String, CodingKey {
        case id, name, serves, description, ingredients, tools, method, isFavourite
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? c.decodeIfPresent(UUID.self, forKey: .id)) ?? UUID()
        name = try c.decodeIfPresent(String.self, forKey: .name)
        serves = try c.decodeIfPresent(Double.self, forKey: .serves)
        description = try c.decodeIfPresent(String.self, forKey: .description)
        ingredients = try c.decodeIfPresent([Ingredient?].self, forKey: .ingredients) ?? []
        tools = try c.decodeIfPresent([String].self, forKey: .tools) ?? []
        method = try c.decodeIfPresent([String].self, forKey: .method) ?? []
        isFavourite = try c.decodeIfPresent(Bool.self, forKey: .isFavourite) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encodeIfPresent(name, forKey: .name)
        try c.encodeIfPresent(serves, forKey: .serves)
        try c.encodeIfPresent(description, forKey: .description)
        try c.encode(ingredients, forKey: .ingredients)
        try c.encode(tools, forKey: .tools)
        try c.encode(method, forKey: .method)
        try c.encode(isFavourite, forKey: .isFavourite)
    }
}

class Ingredient: Codable, Identifiable {
    let id: UUID
    var name: String?
    var quantity: Double?
    var uom: String?
    var quantityPerOneServe: Decimal?

    init(name: String? = nil, quantity: Double? = nil, uom: String? = nil,
         quantityPerOneServe: Decimal? = nil) {
        self.id = UUID()
        self.name = name
        self.quantity = quantity
        self.uom = uom
        self.quantityPerOneServe = quantityPerOneServe
    }

    func getQuantityOfOneForServes(_ serves: Decimal?) -> Decimal {
        Decimal((quantity ?? 0)) / (serves ?? 1)
    }

    enum CodingKeys: String, CodingKey {
        case id, name, quantity, uom, quantityPerOneServe
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? c.decodeIfPresent(UUID.self, forKey: .id)) ?? UUID()
        name = try c.decodeIfPresent(String.self, forKey: .name)
        quantity = try c.decodeIfPresent(Double.self, forKey: .quantity)
        uom = try c.decodeIfPresent(String.self, forKey: .uom)
        if let s = try c.decodeIfPresent(String.self, forKey: .quantityPerOneServe) {
            quantityPerOneServe = Decimal(string: s)
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encodeIfPresent(name, forKey: .name)
        try c.encodeIfPresent(quantity, forKey: .quantity)
        try c.encodeIfPresent(uom, forKey: .uom)
        if let q = quantityPerOneServe { try c.encode("\(q)", forKey: .quantityPerOneServe) }
    }
}

// Intentionally preserves the retain cycle from the UIKit version for educational comparison
class Favourites: Codable {
    var favourites: [Recipe] = []
    var onFavouriteUpdate: (() -> Void)?

    deinit { debugPrint("Favourites deinitialized") }

    func addToFavourites(_ recipe: Recipe) {
        recipe.isFavourite = true
        favourites.append(recipe)
        onFavouriteUpdate = {
            debugPrint("\(recipe.name ?? "Untitled") added to favorites — total: \(self.favourites.count)")
        }
        onFavouriteUpdate?()
    }

    func removeFromFavourites(_ recipe: Recipe) {
        recipe.isFavourite = false
        favourites.removeAll(where: { $0.name == recipe.name })
        onFavouriteUpdate = {
            debugPrint("\(recipe.name ?? "Untitled") removed from favorites — total: \(self.favourites.count)")
        }
        onFavouriteUpdate?()
    }

    init() {}

    enum CodingKeys: String, CodingKey { case favourites }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        favourites = try c.decodeIfPresent([Recipe].self, forKey: .favourites) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(favourites, forKey: .favourites)
    }
}
