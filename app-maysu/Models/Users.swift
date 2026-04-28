//
//  Users.swift
//  app-maysu
//
//  Created by XCODE on 28/04/26.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let nombres: String
    let apellidos: String
    let correo: String
    var profileImageURL: String?
}
