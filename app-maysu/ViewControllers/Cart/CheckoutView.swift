//
//  CheckoutView.swift
//  app-maysu
//
//  Created by XCODE on 28/04/26.
//

import SwiftUI

struct CheckoutView: View {
    @ObservedObject var cartManager = CartManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var cardNumber = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var cardHolder = ""
    @State private var selectedPaymentMethod = 0 // 0: Tarjeta, 1: Efectivo
    
    // Datos del usuario cargados de UserDefaults
    @State private var userName: String = UserDefaults.standard.string(forKey: "nombres") ?? ""
    @State private var userLastName: String = UserDefaults.standard.string(forKey: "apellidos") ?? ""
    @State private var userEmail: String = UserDefaults.standard.string(forKey: "correo") ?? ""
    
    @State private var isProcessing = false
    @State private var showSuccess = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    // Binding para navegar a órdenes después del pago
    @Binding var navigateToOrders: Bool
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // Información del Usuario
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Datos de quien recibe")
                            .font(.headline)
                        
                        HStack(spacing: 15) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.green)
                            
                            VStack(alignment: .leading) {
                                Text("\(userName) \(userLastName)")
                                    .font(.system(size: 18, weight: .bold))
                                Text(userEmail)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Resumen de Orden
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Resumen de tu pedido")
                            .font(.headline)
                        
                        HStack {
                            Text("Total a pagar")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("$\(cartManager.total, specifier: "%.2f")")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Métodos de Pago
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Método de Pago")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Picker("Método", selection: $selectedPaymentMethod) {
                            Text("Tarjeta").tag(0)
                            Text("Efectivo").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        if selectedPaymentMethod == 0 {
                            // Formulario de Tarjeta
                            VStack(spacing: 15) {
                                TextField("Nombre del Titular", text: $cardHolder)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .onAppear {
                                        // Autocompletar con el nombre del usuario si está vacío
                                        if cardHolder.isEmpty {
                                            cardHolder = "\(userName) \(userLastName)".trimmingCharacters(in: .whitespaces)
                                        }
                                    }
                                
                                TextField("Número de Tarjeta", text: $cardNumber)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                
                                HStack {
                                    TextField("MM/YY", text: $expiryDate)
                                        .keyboardType(.numberPad)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                    
                                    TextField("CVV", text: $cvv)
                                        .keyboardType(.numberPad)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal)
                            .transition(.opacity)
                        } else {
                            // Información Pago contra entrega
                            HStack {
                                Image(systemName: "banknote.fill")
                                    .foregroundColor(.green)
                                    .font(.title)
                                Text("Pagarás al recibir tu pedido en efectivo.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .transition(.opacity)
                        }
                    }
                    
                    Spacer(minLength: 50)
                    
                    // Botón de Confirmar
                    Button(action: {
                        processPayment()
                    }) {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .accentColor(.white)
                                    .padding(.trailing, 10)
                            }
                            Text(selectedPaymentMethod == 0 ? "Proceder con el pago" : "Confirmar Pedido")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: Color.green.opacity(0.3), radius: 5, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                    .disabled(isProcessing || (selectedPaymentMethod == 0 && (cardNumber.isEmpty || cardHolder.isEmpty)))
                    
                    Text("Tu pago es seguro y está protegido.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)
                }
                .padding(.top)
            }
            
            // Overlay de éxito
            if showSuccess {
                Color(.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.green)
                    
                    Text("¡Pago Exitoso!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Tu pedido ha sido recibido y está siendo procesado.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    Button(action: {
                        cartManager.clearCart()
                        navigateToOrders = true
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Ver mis pedidos")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                }
            }
        }
        .navigationTitle("Finalizar Compra")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func processPayment() {
        isProcessing = true
        
        // Simular un pequeño delay de pasarela
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            FirestoreService.shared.placeOrder(items: cartManager.items, total: cartManager.total) { result in
                isProcessing = false
                switch result {
                case .success:
                    withAnimation {
                        showSuccess = true
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}
