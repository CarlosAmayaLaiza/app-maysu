//
//  AuthService.swift
//  app-maysu
//
//  Created by XCODE on 27/04/26.
//

import Foundation
import FirebaseAuth

class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    /// Guarda los datos del usuario en UserDefaults para acceso rápido en la UI
    func saveUserSession(nombres: String, apellidos: String, correo: String) {
        let defaults = UserDefaults.standard
        defaults.set(nombres, forKey: "nombres")
        defaults.set(apellidos, forKey: "apellidos")
        defaults.set(correo, forKey: "correo")
        defaults.set(true, forKey: "isLogin")
        
        // Notificar que el usuario ha entrado
        NotificationCenter.default.post(name: AuthService.userDidLoginNotification, object: nil)
    }
    
    /// Limpia los datos de sesión y cierra sesión en Firebase
    func signOut(completion: (Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: "isLogin")
            defaults.removeObject(forKey: "nombres")
            defaults.removeObject(forKey: "apellidos")
            defaults.removeObject(forKey: "correo")
            
            // Limpiar carrito al cerrar sesión para evitar mezcla de datos
            CartManager.shared.clearCart()
            
            completion(nil)
            
            // Notificar a toda la app que la sesión ha terminado
            NotificationCenter.default.post(name: NSNotification.Name("UserDidLogout"), object: nil)
        } catch let error {
            completion(error)
        }
    }
    
    // Nombres de notificaciones centralizados
    static let userDidLogoutNotification = NSNotification.Name("UserDidLogout")
    static let userDidLoginNotification = NSNotification.Name("UserDidLogin")
}
