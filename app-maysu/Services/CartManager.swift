//
//  CartManager.swift
//  app-maysu
//
//  Created by XCODE on 28/04/26.
//

import Foundation
import SwiftUI
import Combine

class CartManager: ObservableObject {
    @Published var items: [CartItem] = [] {
        didSet {
            saveCart()
            NotificationCenter.default.post(name: NSNotification.Name("CartUpdated"), object: nil)
        }
    }
    
    static let shared = CartManager()
    private let cartKey = "maysu_cart_items"
    
    init() {
        loadCart()
    }
    
    var total: Double {
        items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
    
    func addToCart(product: Product) {
        if let index = items.firstIndex(where: { $0.productID == product.id }) {
            items[index].quantity += 1
        } else {
            let newItem = CartItem(
                productID: product.id,
                productName: product.name,
                price: product.price,
                imageName: product.imageName,
                quantity: 1,
                stock: product.stock
            )
            items.append(newItem)
        }
    }
    
    func removeFromCart(productID: String) {
        items.removeAll { $0.productID == productID }
    }
    
    func updateQuantity(productID: String, quantity: Int) {
        if let index = items.firstIndex(where: { $0.productID == productID }) {
            if quantity <= 0 {
                removeFromCart(productID: productID)
            } else {
                items[index].quantity = quantity
            }
        }
    }
    
    func clearCart() {
        items.removeAll()
    }
    
    private func saveCart() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: cartKey)
        }
    }
    
    private func loadCart() {
        if let data = UserDefaults.standard.data(forKey: cartKey),
           let decoded = try? JSONDecoder().decode([CartItem].self, from: data) {
            self.items = decoded
        }
    }
}
