//
//  ProfileView.swift
//  app-maysu
//
//  Created by XCODE on 28/04/26.
//

import SwiftUI

struct ProfileView: View {
    @State private var nombres: String = UserDefaults.standard.string(forKey: "nombres") ?? "Usuario"
    @State private var apellidos: String = UserDefaults.standard.string(forKey: "apellidos") ?? "MaySu"
    @State private var correo: String = UserDefaults.standard.string(forKey: "correo") ?? "usuario@maysu.com"
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
                .padding(.top, 50)
            
            VStack(alignment: .leading, spacing: 15) {
                ProfileInfoRow(label: "Nombre", value: nombres)
                ProfileInfoRow(label: "Apellido", value: apellidos)
                ProfileInfoRow(label: "Correo", value: correo)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Sección de Navegación
            VStack(spacing: 0) {
                NavigationLink(destination: OrdersListView()) {
                    HStack {
                        Image(systemName: "bag.fill")
                            .foregroundColor(.green)
                            .frame(width: 30)
                        Text("Mis Pedidos")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
                
                Divider()
                    .padding(.leading, 50)
                
                Button(action: {
                    // Ayuda o Soporte
                }) {
                    HStack {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        Text("Ayuda y Soporte")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                // Lógica de cerrar sesión podría ir aquí
                UserDefaults.standard.set(false, forKey: "isLogin")
            }) {
                Text("Cerrar Sesión")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .navigationTitle("Mi Perfil")
    }
}

struct ProfileInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .fontWeight(.bold)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
