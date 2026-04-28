//
//  CartView.swift
//  app-maysu
//
//  Created by XCODE on 28/04/26.
//

import SwiftUI

struct CartView: View {
    @ObservedObject var cartManager = CartManager.shared
    @State private var showingCheckoutAlert = false
    @State private var checkoutMessage = ""
    @State private var isProcessing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    if cartManager.items.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "cart.badge.minus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text("Tu carrito está vacío")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text("Parece que aún no has añadido productos de abarrotes a tu carrito.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(cartManager.items) { item in
                                HStack(spacing: 15) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.systemGray6))
                                        .frame(width: 70, height: 70)
                                        .overlay(
                                            Image(systemName: "bag.fill")
                                                .foregroundColor(.green.opacity(0.5))
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(item.productName)
                                            .font(.headline)
                                            .lineLimit(1)
                                        
                                        Text("$\(item.price, specifier: "%.2f") c/u")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        HStack(spacing: 15) {
                                            Button(action: {
                                                cartManager.updateQuantity(productID: item.productID, quantity: item.quantity - 1)
                                            }) {
                                                Image(systemName: "minus.circle.fill")
                                                    .foregroundColor(.green)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            
                                            Text("\(item.quantity)")
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                                .frame(minWidth: 20)
                                            
                                            Button(action: {
                                                cartManager.updateQuantity(productID: item.productID, quantity: item.quantity + 1)
                                            }) {
                                                Image(systemName: "plus.circle.fill")
                                                    .foregroundColor(.green)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                        .padding(.top, 2)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("$\(item.price * Double(item.quantity), specifier: "%.2f")")
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                }
                                .padding(.vertical, 5)
                            }
                            .onDelete { indexSet in
                                indexSet.forEach { index in
                                    let item = cartManager.items[index]
                                    cartManager.removeFromCart(productID: item.productID)
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                        
                        VStack(spacing: 15) {
                            Divider()
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Total a pagar")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("$\(cartManager.total, specifier: "%.2f")")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    processCheckout()
                                }) {
                                    Text("Pagar Ahora")
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 30)
                                        .padding(.vertical, 15)
                                        .background(Color.green)
                                        .cornerRadius(15)
                                        .shadow(color: Color.green.opacity(0.3), radius: 5, x: 0, y: 5)
                                }
                            }
                            .padding(.horizontal, 25)
                            .padding(.bottom, 20)
                        }
                        .background(Color(.systemBackground))
                    }
                }
                
                if isProcessing {
                    Color.black.opacity(0.2)
                        .edgesIgnoringSafeArea(.all)
                    ProgressView("Procesando pedido...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Mi Carrito")
            .toolbar {
                if !cartManager.items.isEmpty {
                    Button("Vaciar") {
                        cartManager.clearCart()
                    }
                    .foregroundColor(.red)
                }
            }
            .alert(isPresented: $showingCheckoutAlert) {
                Alert(
                    title: Text("Pedido"),
                    message: Text(checkoutMessage),
                    dismissButton: .default(Text("Aceptar"))
                )
            }
        }
    }
    
    func processCheckout() {
        isProcessing = true
        FirestoreService.shared.placeOrder(items: cartManager.items, total: cartManager.total) { result in
            isProcessing = false
            switch result {
            case .success:
                checkoutMessage = "¡Tu pedido ha sido recibido! En breve un repartidor se pondrá en contacto contigo."
                cartManager.clearCart()
                showingCheckoutAlert = true
            case .failure(let error):
                checkoutMessage = "Hubo un problema al procesar tu pedido: \(error.localizedDescription)"
                showingCheckoutAlert = true
            }
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
    }
}
