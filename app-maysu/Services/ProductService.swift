//
//  ProductService.swift
//  app-maysu
//
//  Created by XCODE on 27/04/26.
//

import Foundation

class ProductService {
    static let shared = ProductService()
    
    private init() {}
    
    /// Obtiene la lista de productos delegando en FirestoreService
    func getProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
        FirestoreService.shared.fetchProducts(completion: completion)
    }
    
    /// Filtra productos por categoría
    func getProducts(byCategory category: String, completion: @escaping (Result<[Product], Error>) -> Void) {
        getProducts { result in
            switch result {
            case .success(let products):
                let filtered = products.filter { $0.category == category }
                completion(.success(filtered))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
