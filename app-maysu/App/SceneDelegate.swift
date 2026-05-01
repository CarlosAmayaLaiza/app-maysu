//
//  SceneDelegate.swift
//  app-maysu
//
//  Created by XCODE on 10/04/26.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Configurar observadores para cambios de sesión
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogout), name: AuthService.userDidLogoutNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogin), name: AuthService.userDidLoginNotification, object: nil)
        
        // Decidir pantalla inicial basándose en sesión persistente de Firebase
        let isLoginPref = UserDefaults.standard.bool(forKey: "isLogin")
        let hasFirebaseUser = Auth.auth().currentUser != nil
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController: UIViewController
        
        if isLoginPref && hasFirebaseUser {
            initialViewController = storyboard.instantiateViewController(withIdentifier: "menuView")
        } else {
            // Si no hay usuario real, limpiamos por seguridad y vamos al Login
            if isLoginPref && !hasFirebaseUser {
                UserDefaults.standard.set(false, forKey: "isLogin")
            }
            initialViewController = storyboard.instantiateViewController(withIdentifier: "loginView")
        }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = initialViewController
        window?.makeKeyAndVisible()
    }
    
    @objc func handleLogin() {
        guard let window = window else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let menuVC = storyboard.instantiateViewController(withIdentifier: "menuView")
        
        UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromRight, animations: {
            window.rootViewController = menuVC
        }, completion: nil)
    }
    
    @objc func handleLogout() {
        guard let window = window else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "loginView")
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = loginVC
        }, completion: nil)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

