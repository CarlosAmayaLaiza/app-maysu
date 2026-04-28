//
//  ProductCardView.swift
//  app-maysu
//
//  Created by XCODE on 28/04/26.
//

import SwiftUI

struct ProductCard: View {
    let product: Product
    @ObservedObject var cartManager = CartManager.shared
    @State private var showAddedFeedback = false
    
    private var cartItem: CartItem? {
        cartManager.items.first(where: { $0.productID == product.id })
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.systemGray6))
                    .frame(height: 150)
                    .overlay(
                        ZStack {
                            if product.imageName.lowercased().hasPrefix("http") {
                                if let url = URL(string: product.imageName) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .accentColor(.green)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(height: 150)
                                                .clipped()
                                                .cornerRadius(15)
                                        case .failure(let error):
                                            VStack(spacing: 5) {
                                                Image(systemName: "exclamationmark.octagon")
                                                    .foregroundColor(.red.opacity(0.5))
                                                Text("Error URL")
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                            .onAppear {
                                                print("❌ Error cargando imagen remota para \(product.name): \(error.localizedDescription)")
                                            }
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }
                            } else {
                                // Fallback a imagen local si no es una URL
                                Image(product.imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 150)
                                    .clipped()
                                    .cornerRadius(15)
                                    // Si la imagen local tampoco existe, mostrar placeholder
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(.gray.opacity(0.3))
                                            .font(.largeTitle)
                                            .opacity(UIImage(named: product.imageName) == nil ? 1 : 0)
                                    )
                                    .onAppear {
                                        if UIImage(named: product.imageName) == nil {
                                            print("⚠️ No se encontró imagen local ni URL válida para \(product.name): '\(product.imageName)'")
                                        }
                                    }
                            }
                            
                            if showAddedFeedback {
                                Text("¡Añadido!")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.green)
                                    .cornerRadius(10)
                                    .transition(.scale)
                                    .zIndex(1)
                            }
                        }
                    )
                
                if let item = cartItem {
                    HStack(spacing: 8) {
                        Button(action: {
                            cartManager.updateQuantity(productID: product.id, quantity: item.quantity - 1)
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        }) {
                            Image(systemName: "minus")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.green)
                                .clipShape(Circle())
                        }
                        
                        Text("\(item.quantity)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Button(action: {
                            cartManager.updateQuantity(productID: product.id, quantity: item.quantity + 1)
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.green)
                                .clipShape(Circle())
                        }
                    }
                    .padding(5)
                    .background(Color.white)
                    .cornerRadius(25)
                    .shadow(radius: 2)
                    .padding(8)
                } else {
                    Button(action: {
                        cartManager.addToCart(product: product)
                        withAnimation {
                            showAddedFeedback = true
                        }
                        // Feedback háptico
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        
                        // Quitar el feedback después de un segundo
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                showAddedFeedback = false
                            }
                        }
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.green)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .padding(10)
                }
            }
            
            Text(product.name)
                .font(.headline)
                .lineLimit(1)
            
            Text(product.category)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text("$\(product.price, specifier: "%.2f")")
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                Text("/ \(product.unit)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}
