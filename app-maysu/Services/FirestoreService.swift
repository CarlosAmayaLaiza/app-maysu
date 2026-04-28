//
//  FirestoreService.swift
//  app-maysu
//
//  Created by XCODE on 28/04/26.
//

import Foundation
import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Products
    
    func fetchProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
        db.collection("productos").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            var products: [Product] = []
            for document in querySnapshot!.documents {
                let data = document.data()
                if let product = self.parseProduct(id: document.documentID, data: data) {
                    products.append(product)
                }
            }
            completion(.success(products))
        }
    }
    
    private func parseProduct(id: String, data: [String: Any]) -> Product? {
        guard let name = data["nombre"] as? String,
              let description = data["descripcion"] as? String,
              let price = data["precio"] as? Double,
              let imageName = data["imagen"] as? String,
              let category = data["categoria"] as? String,
              let unit = data["unidad"] as? String else {
            return nil
        }
        
        return Product(
            id: id,
            name: name,
            description: description,
            price: price,
            imageName: imageName,
            category: category,
            unit: unit
        )
    }
    
    // MARK: - Orders
    
    func placeOrder(items: [CartItem], total: Double, completion: @escaping (Result<String, Error>) -> Void) {
        let orderData: [String: Any] = [
            "items": items.map { [
                "productID": $0.productID,
                "productName": $0.productName,
                "price": $0.price,
                "quantity": $0.quantity
            ]},
            "total": total,
            "status": "Pendiente",
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("ordenes").addDocument(data: orderData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("Orden creada con éxito"))
            }
        }
    }
    
    func fetchOrders(completion: @escaping (Result<[Order], Error>) -> Void) {
        db.collection("ordenes").order(by: "timestamp", descending: true).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            var orders: [Order] = []
            for document in querySnapshot!.documents {
                let data = document.data()
                if let order = self.parseOrder(id: document.documentID, data: data) {
                    orders.append(order)
                }
            }
            completion(.success(orders))
        }
    }
    
    private func parseOrder(id: String, data: [String: Any]) -> Order? {
        guard let total = data["total"] as? Double,
              let status = data["status"] as? String,
              let timestamp = data["timestamp"] as? Timestamp,
              let itemsData = data["items"] as? [[String: Any]] else {
            return nil
        }
        
        let items = itemsData.compactMap { itemData -> OrderItem? in
            guard let productID = itemData["productID"] as? String,
                  let productName = itemData["productName"] as? String,
                  let price = itemData["price"] as? Double,
                  let quantity = itemData["quantity"] as? Int else {
                return nil
            }
            return OrderItem(productID: productID, productName: productName, price: price, quantity: quantity)
        }
        
        return Order(
            id: id,
            userID: "user_default", // Por ahora, ya que no tenemos Auth completo
            date: timestamp.dateValue(),
            total: total,
            status: status,
            items: items
        )
    }
}
