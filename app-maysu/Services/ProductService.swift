//
//  ProductService.swift
//  app-maysu
//
//  Created by XCODE on 27/04/26.
//

import Foundation

class ProductService {
    static let shared = ProductService()
    
    private var cachedProducts: [Product] = []
    private var lastCacheUpdate: Date?
    private let cacheDuration: TimeInterval = 300 // 5 minutos
    
    private init() {}
    
    /// Obtiene la lista de productos con caché en memoria
    func getProducts(forceRefresh: Bool = false, completion: @escaping (Result<[Product], Error>) -> Void) {
        // Si hay caché y no ha expirado, devolverla (a menos que se pida refresh forzado)
        if !forceRefresh, let lastUpdate = lastCacheUpdate, Date().timeIntervalSince(lastUpdate) < cacheDuration, !cachedProducts.isEmpty {
            completion(.success(cachedProducts))
            return
        }
        
        FirestoreService.shared.fetchProducts { result in
            switch result {
            case .success(let products):
                self.cachedProducts = products
                self.lastCacheUpdate = Date()
                completion(.success(products))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Filtra productos por categoría usando el servidor (Firestore)
    func getProducts(byCategory category: String, completion: @escaping (Result<[Product], Error>) -> Void) {
        // En este caso no usamos caché global porque es una consulta específica
        FirestoreService.shared.fetchProducts(category: category, completion: completion)
    }
}
