//
//  CartView.swift
//  app-maysu
//
//  Created by XCODE on 28/04/26.
//

import SwiftUI

struct CartView: View {
    @State private var cartItems: [CartItem] = [] // Assuming CartItem exists in Models
    
    var body: some View {
        NavigationView {
            VStack {
                if cartItems.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "cart.badge.minus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                        
                        Text("Tu carrito está vacío")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("¡Explora nuestro catálogo y añade algo increíble!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(cartItems) { item in
                            HStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.green.opacity(0.1))
                                    .frame(width: 60, height: 60)
                                    .overlay(Image(systemName: "bag").foregroundColor(.green))
                                
                                VStack(alignment: .leading) {
                                    Text(item.productName)
                                        .font(.headline)
                                    Text("Cantidad: \(item.quantity)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("$\(item.price * Double(item.quantity), specifier: "%.2f")")
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    
                    VStack(spacing: 15) {
                        HStack {
                            Text("Total")
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                            Text("$\(totalAmount, specifier: "%.2f")")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal)
                        
                        Button(action: {
                            // Acción de checkout
                        }) {
                            Text("Finalizar Compra")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
            }
            .navigationTitle("Carrito")
        }
    }
    
    private var totalAmount: Double {
        cartItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
    }
}
