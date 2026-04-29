//
//  RegisterViewController.swift
//  app-maysu
//
//  Created by XCODE on 28/04/26.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegisterViewController: UIViewController {

    @IBOutlet weak var txtNombres: UITextField!
    @IBOutlet weak var txtApellidos: UITextField!
    @IBOutlet weak var txtCorreo: UITextField!
    @IBOutlet weak var txtContraseña: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoader()
        let tap = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
        view.addGestureRecognizer(tap)
    }
    
    private func setupLoader() {
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    @objc func ocultarTeclado() {
        view.endEditing(true)
    }

    @IBAction func registrar(_ sender: UIButton) {
        guard let nombres = txtNombres.text, !nombres.isEmpty,
              let apellidos = txtApellidos.text, !apellidos.isEmpty,
              let correo = txtCorreo.text, !correo.isEmpty,
              let password = txtContraseña.text, !password.isEmpty else {
            mostrarAlerta(titulo: "Error", mensaje: "Todos los campos son obligatorios")
            return
        }
        
        activityIndicator.startAnimating()
        sender.isEnabled = false
        
        Auth.auth().createUser(withEmail: correo, password: password) { authResult, error in
            if let error = error {
                self.activityIndicator.stopAnimating()
                sender.isEnabled = true
                self.mostrarAlerta(titulo: "Error de Registro", mensaje: error.localizedDescription)
                return
            }
            
            guard let uid = authResult?.user.uid else { return }
            
            // Guardar en Firestore
            let db = Firestore.firestore()
            db.collection("usuarios").document(uid).setData([
                "nombres": nombres,
                "apellidos": apellidos,
                "correo": correo,
                "uid": uid
            ]) { error in
                self.activityIndicator.stopAnimating()
                sender.isEnabled = true
                
                if let error = error {
                    self.mostrarAlerta(titulo: "Error al guardar", mensaje: error.localizedDescription)
                } else {
                    // GUARDAR SESIÓN: Para que al registrarse ya tenga sus datos en el perfil
                    AuthService.shared.saveUserSession(nombres: nombres, apellidos: apellidos, correo: correo)
                    
                    let alerta = UIAlertController(title: "Éxito", message: "Usuario registrado correctamente", preferredStyle: .alert)
                    alerta.addAction(UIAlertAction(title: "Aceptar", style: .default) { _ in
                        self.dismiss(animated: true)
                    })
                    self.present(alerta, animated: true)
                }
            }
        }
    }
    
    @IBAction func regresarLogin(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func mostrarAlerta(titulo: String, mensaje: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Aceptar", style: .default))
        self.present(alerta, animated: true)
    }
}
