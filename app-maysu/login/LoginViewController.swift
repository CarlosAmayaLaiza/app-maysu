//
//  LoginViewController.swift
//  app-maysu
//
//  Created by XCODE on 11/04/26.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var txtCorreo: UITextField!
    
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

  
      @IBAction func btnIngresar(_ sender: UIButton) {
          let correo = txtCorreo.text ?? ""
          let clave = txtPassword.text ?? ""
          
          Auth.auth().signIn(withEmail: correo, password: clave) {(authResult, error) in
                  // authResult != null - login correcto
                  // error != null - login incorrecto
              if let result = authResult {
                  let uid = result.user.uid
                  print("El usuario con uid: \(uid) se ha logueado")
                  // ir al home - menu principal
                  let storyboard = UIStoryboard(name: "Main", bundle: nil)
                  let view = storyboard.instantiateViewController(withIdentifier: "menuView")
                  view.modalPresentationStyle = .fullScreen
                  self.present(view, animated: true)
              } else {
                  print("Error al intentar loguearse")
              }
          }
      }
}
