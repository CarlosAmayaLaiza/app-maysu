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
    let status: String
    let items: [OrderItem]
    
    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
}
