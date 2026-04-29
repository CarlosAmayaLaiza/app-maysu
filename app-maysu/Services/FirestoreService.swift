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
              let category = data["categoria"] as? String,
              let unit = data["unidad"] as? String else {
            return nil
        }
        
        let price: Double = (data["precio"] as? Double) ?? Double(data["precio"] as? Int ?? 0)
        let imageName = data["imagen"] as? String ?? ""
        
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
                "imageName": $0.imageName,
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
        print("📡 FirestoreService: Obteniendo pedidos...")
        db.collection("ordenes").order(by: "timestamp", descending: true).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("❌ FirestoreService: Error al obtener pedidos: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            let documents = querySnapshot?.documents ?? []
            print("✅ FirestoreService: Se encontraron \(documents.count) documentos en 'ordenes'")
            
            var orders: [Order] = []
            for document in documents {
                let data = document.data()
                if let order = self.parseOrder(id: document.documentID, data: data) {
                    orders.append(order)
                } else {
                    print("⚠️ FirestoreService: No se pudo parsear el pedido \(document.documentID)")
                }
            }
            print("📦 FirestoreService: \(orders.count) pedidos parseados con éxito")
            completion(.success(orders))
        }
    }
    
    private func parseOrder(id: String, data: [String: Any]) -> Order? {
        let total: Double = (data["total"] as? Double) ?? Double(data["total"] as? Int ?? 0)
        let status = data["status"] as? String ?? "Pendiente"
        let userID = data["userID"] as? String ?? "unknown"
        
        // Manejar timestamp
        let date = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
        
        guard let itemsData = data["items"] as? [[String: Any]] else { return nil }
        
        let items = itemsData.compactMap { itemData -> OrderItem? in
            guard let productID = itemData["productID"] as? String,
                  let productName = itemData["productName"] as? String else {
                return nil
            }
            
            let price: Double = (itemData["price"] as? Double) ?? Double(itemData["price"] as? Int ?? 0)
            let quantity = itemData["quantity"] as? Int ?? 1
            let imageName = itemData["imageName"] as? String ?? ""
            
            return OrderItem(productID: productID, productName: productName, price: price, imageName: imageName, quantity: quantity)
        }
        
        return items.isEmpty ? nil : Order(
            id: id,
            userID: userID,
            date: date,
            total: total,
            status: status,
            items: items
        )
    }
}
