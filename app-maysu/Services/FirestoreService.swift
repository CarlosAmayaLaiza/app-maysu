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
    
    func fetchProducts(category: String? = nil, completion: @escaping (Result<[Product], Error>) -> Void) {
        var query: Query = db.collection("productos")
        
        if let category = category {
            query = query.whereField("categoria", isEqualTo: category)
        }
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion(.success([]))
                return
            }
            
            var products: [Product] = []
            for document in documents {
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
        let stock = data["stock"] as? Int ?? (data["cantidad"] as? Int ?? 0)
        
        return Product(
            id: id,
            name: name,
            description: description,
            price: price,
            imageName: imageName,
            category: category,
            unit: unit,
            stock: stock
        )
    }
    
    // MARK: - Orders
    
    func placeOrder(items: [CartItem], total: Double, userID: String, paymentMethod: String, address: String, completion: @escaping (Result<String, Error>) -> Void) {
        let orderRef = db.collection("ordenes").document()
        let orderData: [String: Any] = [
            "items": items.map { [
                "productID": $0.productID,
                "productName": $0.productName,
                "price": $0.price,
                "imageName": $0.imageName,
                "quantity": $0.quantity
            ]},
            "total": total,
            "userID": userID,
            "paymentMethod": paymentMethod,
            "address": address,
            "status": "Pendiente",
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            // 1. Verificar y actualizar stock para cada producto
            for item in items {
                let productRef = self.db.collection("productos").document(item.productID)
                let productSnapshot: DocumentSnapshot
                do {
                    productSnapshot = try transaction.getDocument(productRef)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                
                guard let data = productSnapshot.data(),
                      let oldStock = data["stock"] as? Int ?? (data["cantidad"] as? Int) else {
                    let error = NSError(domain: "InventoryError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Producto \(item.productName) no encontrado o sin stock definido."])
                    errorPointer?.pointee = error
                    return nil
                }
                
                if oldStock < item.quantity {
                    let error = NSError(domain: "InventoryError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Stock insuficiente para \(item.productName). Disponible: \(oldStock)"])
                    errorPointer?.pointee = error
                    return nil
                }
                
                // Restar stock
                transaction.updateData(["stock": oldStock - item.quantity], forDocument: productRef)
            }
            
            // 2. Crear la orden
            transaction.setData(orderData, forDocument: orderRef)
            
            return "Éxito"
        }) { (object, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("Orden creada con éxito"))
            }
        }
    }
    
    func fetchOrders(userID: String, completion: @escaping (Result<[Order], Error>) -> Void) {
        print("📡 FirestoreService: Obteniendo pedidos para el usuario \(userID)...")
        db.collection("ordenes")
            .whereField("userID", isEqualTo: userID)
            .order(by: "timestamp", descending: true)
            .getDocuments { (querySnapshot, error) in
            if let error = error {
                print("❌ FirestoreService: Error al obtener pedidos: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            let documents = querySnapshot?.documents ?? []
            var orders: [Order] = []
            for document in documents {
                let data = document.data()
                if let order = self.parseOrder(id: document.documentID, data: data) {
                    orders.append(order)
                }
            }
            completion(.success(orders))
        }
    }
    
    private func parseOrder(id: String, data: [String: Any]) -> Order? {
        let total: Double = (data["total"] as? Double) ?? Double(data["total"] as? Int ?? 0)
        let status = data["status"] as? String ?? "Pendiente"
        let userID = data["userID"] as? String ?? "unknown"
        let paymentMethod = data["paymentMethod"] as? String ?? "No especificado"
        let address = data["address"] as? String ?? "Sin dirección"
        
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
            address: address,
            status: status,
            paymentMethod: paymentMethod,
            items: items
        )
    }
}
