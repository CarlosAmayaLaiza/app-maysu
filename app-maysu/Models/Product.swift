//
//  Product.swift
//  app-maysu
//
//  Created by XCODE on 27/04/26.
//

import Foundation

struct Product: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let imageName: String
    let category: String
    let unit: String // kg, pza, lt, etc.
}

extension Product {
    static let sampleData: [Product] = [
        // Frutas y Verduras
        Product(id: "1", name: "Manzana Roja", description: "Manzana roja dulce y fresca.", price: 45.0, imageName: "manzana", category: "Frutas y Verduras", unit: "kg"),
        Product(id: "2", name: "Plátano Tabasco", description: "Plátano de gran sabor y madurez.", price: 22.5, imageName: "platano", category: "Frutas y Verduras", unit: "kg"),
        
        // Lácteos
        Product(id: "3", name: "Leche Entera 1L", description: "Leche de vaca pasteurizada.", price: 26.0, imageName: "leche", category: "Lácteos", unit: "lt"),
        Product(id: "4", name: "Queso Panela", description: "Queso fresco tipo panela de 400g.", price: 65.0, imageName: "queso", category: "Lácteos", unit: "pza"),
        
        // Abarrotes
        Product(id: "5", name: "Arroz Blanco 1kg", description: "Arroz grano largo de alta calidad.", price: 32.0, imageName: "arroz", category: "Abarrotes", unit: "pza"),
        Product(id: "6", name: "Aceite Vegetal 1L", description: "Aceite para cocinar 100% puro.", price: 48.0, imageName: "aceite", category: "Abarrotes", unit: "lt"),
        
        // Bebidas
        Product(id: "7", name: "Refresco de Cola 2L", description: "Bebida gaseosa sabor original.", price: 38.0, imageName: "refresco", category: "Bebidas", unit: "pza"),
        Product(id: "8", name: "Agua Natural 1.5L", description: "Agua purificada embotellada.", price: 16.5, imageName: "agua", category: "Bebidas", unit: "pza"),
        
        // Limpieza
        Product(id: "9", name: "Detergente en Polvo", description: "Detergente multiusos de 1kg.", price: 35.0, imageName: "detergente", category: "Limpieza", unit: "pza"),
        Product(id: "10", name: "Limpiador Multiusos 1L", description: "Limpiador con aroma a lavanda.", price: 24.0, imageName: "limpiador", category: "Limpieza", unit: "lt")
    ]
}
