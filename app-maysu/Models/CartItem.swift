//
//  CartItem.swift
//  app-maysu
//
//  Created by XCODE on 28/04/26.
//

import Foundation

struct CartItem: Identifiable, Codable {
    var id: String { productID }
    let productID: String
    let productName: String
    let price: Double
    let imageName: String
    var quantity: Int
    let stock: Int
}
