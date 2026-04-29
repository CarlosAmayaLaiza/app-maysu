//
//  Order.swift
//  app-maysu
//
//  Created by XCODE on 28/04/26.
//

import Foundation

struct Order: Identifiable, Codable {
    let id: String
    let userID: String
    let date: Date
    let total: Double
    let address: String
    let status: String
    let paymentMethod: String
    let items: [OrderItem]
    
    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
}

struct OrderItem: Identifiable, Codable {
    var id: String { productID }
    let productID: String
    let productName: String
    let price: Double
    let imageName: String
    let quantity: Int
}
