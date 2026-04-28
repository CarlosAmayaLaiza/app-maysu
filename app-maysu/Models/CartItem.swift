//
//  CartItem.swift
//  app-maysu
//
//  Created by XCODE on 28/04/26.
//

import Foundation

struct CartItem: Identifiable, Codable {
    var id = UUID()
    let productID: String
    let productName: String
    let price: Double
    var quantity: Int
}
