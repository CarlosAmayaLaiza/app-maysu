import UIKit
import FirebaseAuth
import FirebaseFirestore


class LoginViewController: UIViewController {
    
    @IBOutlet weak var txtCorreo: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
        view.addGestureRecognizer(tap)
        
    }
    @objc func ocultarTeclado() {
        view.endEditing(true)
    }
    
    @IBAction func btnIngresar(_ sender: UIButton) {
        let correo = txtCorreo.text ?? ""
        let clave = txtPassword.text ?? ""
        
        // 1. Validar que los campos no estén vacíos
        if correo.isEmpty || clave.isEmpty {
            self.mostrarAlerta(titulo: "Campos vacíos", mensaje: "Por favor, completa todos los datos.")
            return
        }
        
        // 2. Validar formato de correo
        if !validarEmail(correo) {
            self.mostrarAlerta(titulo: "Correo inválido", mensaje: "Por favor, ingresa un formato de correo electrónico válido.")
            return
        }
        
        // 3. Validar longitud de contraseña
        if clave.count < 3 {
            self.mostrarAlerta(titulo: "Contraseña corta", mensaje: "La contraseña debe tener al menos 3 caracteres.")
            return
        }
        
        Auth.auth().signIn(withEmail: correo, password: clave) { (authResult, error) in
            if let error = error {
                // Si hay error, mostramos la alerta de falla con el mensaje real
                self.mostrarAlerta(titulo: "Error de Inicio", mensaje: error.localizedDescription)
            } else if let uid = authResult?.user.uid {
                // LLAMADA A LA FUNCIÓN FALTANTE: Obtener datos del perfil antes de entrar
                self.getDataFireStore(uid: uid) { success in
                    if success {
                        // 1. Creamos la alerta de éxito
                        let alertaExito = UIAlertController(
                            title: "¡Bienvenido!",
                            message: "Inicio de sesión exitoso.",
                            preferredStyle: .alert
                        )
                        
                        // 2. Creamos la acción (el botón) y metemos el código de navegación dentro
                        let accionIrAlMenu = UIAlertAction(title: "Entrar", style: .default) { _ in
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let view = storyboard.instantiateViewController(withIdentifier: "menuView")
                            view.modalPresentationStyle = .fullScreen
                            self.present(view, animated: true)
                        }
                        
                        alertaExito.addAction(accionIrAlMenu)
                        self.present(alertaExito, animated: true)
                    } else {
                        self.mostrarAlerta(titulo: "Error de Perfil", mensaje: "No se pudieron cargar tus datos de usuario.")
                    }
                }
            }
        }
    }
    
    // Función para validar el formato del correo mediante Regex
    func validarEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // Función auxiliar para mostrar alertas de error rápidas
    func mostrarAlerta(titulo: String, mensaje: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Aceptar", style: .default))
        self.present(alerta, animated: true)
    }
    
    @IBAction func abrirRegistrate(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let view = storyboard.instantiateViewController(withIdentifier: "registerView")
            view.modalPresentationStyle = .fullScreen
            self.present(view, animated: true)
    }
    
    func getDataFireStore(uid: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let docRef = db.collection("usuarios").document(uid)
        docRef.getDocument { (document, error) in
            if let error = error {
                print("Error al obtener datos: \(error.localizedDescription)")
                completion(false)
                return
            }
            if let document = document, document.exists {
                let data = document.data()
                let nombres = data?["nombres"] as? String ?? ""
                let apellidos = data?["apellidos"] as? String ?? ""
                let correo = data?["correo"] as? String ?? ""
                
                AuthService.shared.saveUserSession(nombres: nombres, apellidos: apellidos, correo: correo)
                completion(true)
            } else {
                print("Document does not exist")
                completion(false)
            }
        }
    }
}
