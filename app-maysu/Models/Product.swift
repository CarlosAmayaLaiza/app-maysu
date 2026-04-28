//
//  Product.swift
//  app-maysu
//
//  Created by XCODE on 27/04/26.
//

import Foundation

struct Product: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let imageName: String
    let category: String
    let unit: String // kg, pza, lt, etc.
}
