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
        // Log para depuración
        print("🔍 Parseando orden \(id): \(data)")
        
        // Manejar total como Double o Int
        let total: Double
        if let t = data["total"] as? Double {
            total = t
        } else if let t = data["total"] as? Int {
            total = Double(t)
        } else {
            print("❌ Fallo en total para \(id)")
            return nil
        }
        
        let status = data["status"] as? String ?? "Pendiente"
        
        // Manejar timestamp opcional
        let date: Date
        if let ts = data["timestamp"] as? Timestamp {
            date = ts.dateValue()
        } else {
            date = Date() // Fallback a fecha actual
            print("⚠️ Usando fecha actual para \(id) (timestamp faltante)")
        }
        
        guard let itemsData = data["items"] as? [[String: Any]] else {
            print("❌ Fallo en items para \(id)")
            return nil
        }
        
        let items = itemsData.compactMap { itemData -> OrderItem? in
            guard let productID = itemData["productID"] as? String,
                  let productName = itemData["productName"] as? String else {
                return nil
            }
            
            // Manejar precio como Double o Int
            let price: Double
            if let p = itemData["price"] as? Double {
                price = p
            } else if let p = itemData["price"] as? Int {
                price = Double(p)
            } else {
                price = 0.0
            }
            
            let quantity = itemData["quantity"] as? Int ?? 1
            let imageName = itemData["imageName"] as? String ?? ""
            
            return OrderItem(productID: productID, productName: productName, price: price, imageName: imageName, quantity: quantity)
        }
        
        if items.isEmpty {
            print("❌ Orden \(id) no tiene items válidos")
            return nil
        }
        
        return Order(
            id: id,
            userID: data["userID"] as? String ?? "user_default",
            date: date,
            total: total,
            status: status,
            items: items
        )
    }
}
