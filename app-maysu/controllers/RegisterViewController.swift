import UIKit
import FirebaseFirestore
import FirebaseAuth


class RegisterViewController: UIViewController {
    
    @IBOutlet weak var txtNombres: UITextField!
    @IBOutlet weak var txtApellidos: UITextField!
    @IBOutlet weak var txtCorreo: UITextField!
    @IBOutlet weak var txtContraseña: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
        view.addGestureRecognizer(tap)
    }

    @objc func ocultarTeclado() {
        view.endEditing(true)
    }
    
    @IBAction func registrar(_ sender: Any) {
        let nombres = txtNombres.text ?? ""
        let apellidos = txtApellidos.text ?? ""
        let correo = txtCorreo.text ?? ""
        let contraseña = txtContraseña.text ?? ""
        
        if nombres.isEmpty || apellidos.isEmpty || correo.isEmpty || contraseña.isEmpty {
            mostrarAlerta(titulo: "Campos vacíos", mensaje: "Completa todos los campos")
            return
        }
        
        if contraseña.count < 6 {
            mostrarAlerta(titulo: "Contraseña débil", mensaje: "Mínimo 6 caracteres")
            return
        }
        
        registerAuth(correo: correo, contraseña: contraseña, nombres: nombres, apellidos: apellidos)
    }
    
    func mostrarAlerta(titulo: String, mensaje: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Aceptar", style: .default))
        self.present(alerta, animated: true)
    }
    
    private func registerAuth(correo: String, contraseña: String, nombres: String, apellidos: String) {
        Auth.auth().createUser(withEmail: correo, password: contraseña) { (result, error) in
            if let error = error {
                print("Error al crear usuario")
                self.mostrarAlerta(titulo: "Error", mensaje: "No se pudo crear el usuario. Intenta de nuevo.")
            } else if let result = result {
                print("Usuario creado exitosamente")
                let uid = result.user.uid
                self.registerFirestore(uid: uid, nombres: nombres, apellidos: apellidos, correo: correo)
            }
        }
    }
    
    private func registerFirestore(uid: String, nombres: String, apellidos: String, correo: String) {
        let db = Firestore.firestore()
        let data: [String: Any] = ["Nombres": nombres, "Apellidos": apellidos, "correo": correo]
        
        db.collection("usuarios").document(uid).setData(data) { error in
            if let error = error {
                print("Error al guardar en Firestore")
                self.mostrarAlerta(titulo: "Error", mensaje: "No se pudieron guardar los datos. Intenta de nuevo.")
            } else {
                print("Datos guardados exitosamente")
                
                // ✅ Alerta de éxito — al presionar "Aceptar" cierra la pantalla
                let alertaExito = UIAlertController(
                    title: "¡Registro exitoso!",
                    message: "Tu cuenta ha sido creada correctamente.",
                    preferredStyle: .alert
                )
                let accionAceptar = UIAlertAction(title: "Aceptar", style: .default) { _ in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let loginVC = storyboard.instantiateViewController(withIdentifier: "menuView")
                    loginVC.modalPresentationStyle = .fullScreen
                    self.present(loginVC, animated: true)
                }
                alertaExito.addAction(accionAceptar)
                self.present(alertaExito, animated: true)
            }
        }
    }
}
