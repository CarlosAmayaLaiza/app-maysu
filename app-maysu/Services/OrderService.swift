import Foundation
import FirebaseAuth

class OrderService {
    static let shared = OrderService()
    
    private init() {}
    
    /// Crea un nuevo pedido con el ID del usuario y método de pago
    func createOrder(items: [CartItem], total: Double, paymentMethod: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Usuario no autenticado"])))
            return
        }
        
        FirestoreService.shared.placeOrder(items: items, total: total, userID: uid, paymentMethod: paymentMethod, completion: completion)
    }
    
    /// Obtiene el historial de pedidos filtrado por el usuario actual
    func getOrderHistory(completion: @escaping (Result<[Order], Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Usuario no autenticado"])))
            return
        }
        
        FirestoreService.shared.fetchOrders(userID: uid, completion: completion)
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
