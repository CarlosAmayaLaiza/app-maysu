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
                // Si hay error, mostramos la alerta de falla
                self.mostrarAlerta(titulo: "Error de Inicio", mensaje: "Credenciales incorrectas o problema de conexión.")
            } else {
                // 1. Creamos la alerta de éxito
                let alertaExito = UIAlertController(
                    title: "¡Bienvenido!",
                    message: "Inicio de sesión exitoso.",
                    preferredStyle: .alert
                )
                
                // 2. Creamos la acción (el botón) y metemos el código de navegación dentro
                let accionIrAlMenu = UIAlertAction(title: "Entrar", style: .default) { _ in
                    // Este código solo se ejecuta cuando el usuario presiona "Entrar"
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let view = storyboard.instantiateViewController(withIdentifier: "menuView")
                    view.modalPresentationStyle = .fullScreen
                    self.present(view, animated: true)
                }
                
                // 3. Agregamos el botón a la alerta y la mostramos
                alertaExito.addAction(accionIrAlMenu)
                self.present(alertaExito, animated: true)
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
    
    func getDataFireStore(uid:String){
        let db = Firestore.firestore()
        let docRef = db.collection("usuarios").document(uid)
        docRef.getDocument{(document, error)in
            if let document = document, document.exists{
                let data = document.data()
                let nombres = data?["nombres"] as! String
                let apellidos = data?["apellidos"] as! String
                let correo = data?["correo"] as! String
                
                self.saveDataSession(nombres: nombres, apellidos: apellidos, correo: correo)
                
            } else {
                let dataDescription = "nil" as Any
                print("Document does not exist: \(dataDescription)")
            }
        }
            
    }
    
    func saveDataSession(nombres: String, apellidos: String, correo: String){
        let userDefaults = UserDefaults.standard
        userDefaults.set(nombres, forKey: "nombres")
        userDefaults.set(apellidos, forKey: "apellidos")
        userDefaults.set(correo, forKey: "correo")
        userDefaults.set(true, forKey: "isLogin")
    }
    
}
