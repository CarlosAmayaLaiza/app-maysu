//
//  HomeView.swift
//  app-maysu
//
//  Created by XCODE on 28/04/26.
//

import SwiftUI

struct HomeView: View {
    let featuredProducts = Array(Product.sampleData.prefix(3))
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Bienvenida
                VStack(alignment: .leading) {
                    Text("¡Hola de nuevo!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Encuentra lo mejor para tu hogar.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Banner Promocional
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 150)
                    
                    VStack {
                        Text("Ofertas de Temporada")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Hasta 50% de descuento")
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                
                // Productos Destacados
                Text("Productos Destacados")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(featuredProducts) { product in
                            VStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.green.opacity(0.2))
                                    .frame(width: 140, height: 100)
                                    .overlay(
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.green)
                                    )
                                
                                Text(product.name)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text("$\(product.price, specifier: "%.2f")")
                                    .font(.caption2)
                            }
                            .frame(width: 140)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
