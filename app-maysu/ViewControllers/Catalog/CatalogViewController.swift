//
//  CatalogViewController.swift
//  app-maysu
//
//  Created by XCODE on 27/04/26.
//

import UIKit
import SwiftUI

class CatalogViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSwiftUIView()
    }
    
    private func setupSwiftUIView() {
        // Creamos la vista de SwiftUI
        let swiftUIView = ProductListView()
        
        // La envolvemos en un UIHostingController
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        // Agregamos el hostingController como hijo
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        // Configuramos las constraints para que ocupe toda la pantalla
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
}
