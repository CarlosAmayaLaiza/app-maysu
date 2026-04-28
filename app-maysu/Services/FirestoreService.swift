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
    
    // MARK: - Sync Initial Data (Optional Helper)
    
    func uploadSampleData() {
        let sampleProducts = Product.sampleData
        print("📦 FirestoreService: Preparando subida de \(sampleProducts.count) productos...")
        
        // Configuración para mejorar la estabilidad en el simulador
        let settings = db.settings
        settings.isPersistenceEnabled = false // Desactivar persistencia temporalmente para forzar subida limpia
        db.settings = settings
        
        for product in sampleProducts {
            let docRef = db.collection("productos").document(product.id)
            
            print("⏳ Enviando a la nube: \(product.name)...")
            
            docRef.setData([
                "nombre": product.name,
                "descripcion": product.description,
                "precio": product.price,
                "imagen": product.imageName,
                "categoria": product.category,
                "unidad": product.unit,
                "timestamp": FieldValue.serverTimestamp()
            ]) { error in
                if let error = error {
                    print("❌ ERROR en \(product.name): \(error.localizedDescription)")
                } else {
                    print("✅ ÉXITO: \(product.name) ya está en Firestore")
                }
            }
        }
    }
}
