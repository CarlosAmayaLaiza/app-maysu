//
//  OrderService.swift
//  app-maysu
//
//  Created by XCODE on 27/04/26.
//

import Foundation

class OrderService {
    static let shared = OrderService()
    
    private init() {}
    
    /// Crea un nuevo pedido
    func createOrder(items: [CartItem], total: Double, completion: @escaping (Result<String, Error>) -> Void) {
        FirestoreService.shared.placeOrder(items: items, total: total, completion: completion)
    }
    
    /// Obtiene el historial de pedidos
    func getOrderHistory(completion: @escaping (Result<[Order], Error>) -> Void) {
        FirestoreService.shared.fetchOrders(completion: completion)
    }
    
    /// Calcula el estado de una orden para mostrar colores en la UI (Lógica de negocio)
    func getStatusInfo(status: String) -> (text: String, colorName: String) {
        switch status.lowercased() {
        case "entregado": return ("Entregado", "green")
        case "pendiente": return ("Pendiente", "orange")
        case "cancelado": return ("Cancelado", "red")
        default: return (status, "blue")
        }
    }
}
