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
}

extension Product {
    static let sampleData: [Product] = [
        Product(id: "1", name: "Silla de Oficina", description: "Silla ergonómica para oficina con soporte lumbar.", price: 120.0, imageName: "silla", category: "Muebles"),
        Product(id: "2", name: "Lámpara de Escritorio", description: "Lámpara LED con ajuste de brillo.", price: 35.5, imageName: "lampara", category: "Iluminación"),
        Product(id: "3", name: "Escritorio de Madera", description: "Escritorio amplio de madera de roble.", price: 250.0, imageName: "escritorio", category: "Muebles"),
        Product(id: "4", name: "Organizador de Cables", description: "Set de 5 organizadores para cables.", price: 15.0, imageName: "organizador", category: "Accesorios")
    ]
}
