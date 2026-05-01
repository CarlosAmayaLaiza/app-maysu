//
//  HomeView.swift
//  app-maysu
//
//  Created by XCODE on 28/04/26.
//

import SwiftUI

struct HomeView: View {
    @State private var featuredProducts: [Product] = []
    @State private var isLoading = true
    
    let categories = [
        ("Frutas y Verduras", "leaf.fill", Color.green),
        ("Lácteos", "drop.fill", Color.blue),
        ("Abarrotes", "cart.fill", Color.orange),
        ("Bebidas", "cup.and.saucer.fill", Color.purple),
        ("Limpieza", "sparkles", Color.teal)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // Bienvenida
                    VStack(alignment: .leading) {
                        Text("Tienda MaySu")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        Text("Tus abarrotes frescos y a domicilio.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Banner de Oferta
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(LinearGradient(gradient: Gradient(colors: [Color.green, Color.green.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(height: 140)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Frutas Frescas")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text("20% de descuento en tu primer pedido")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            Spacer()
                            Image(systemName: "basket.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80)
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .padding(25)
                    }
                    .padding(.horizontal)
                    
                    // Categorías
                    VStack(alignment: .leading) {
                        Text("Categorías")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(categories, id: \.0) { category in
                                    NavigationLink(destination: ProductListView(initialCategory: category.0)) {
                                        VStack {
                                            ZStack {
                                                Circle()
                                                    .fill(category.2.opacity(0.1))
                                                    .frame(width: 60, height: 60)
                                                Image(systemName: category.1)
                                                    .foregroundColor(category.2)
                                                    .font(.title3)
                                            }
                                            Text(category.0)
                                                .font(.caption2)
                                                .fontWeight(.medium)
                                                .foregroundColor(.primary)
                                        }
                                        .frame(width: 80)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Productos Destacados
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Ofertas del Día")
                                .font(.headline)
                            Spacer()
                            NavigationLink(destination: ProductListView()) {
                                Text("Ver todo")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.horizontal)
                        
                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .padding()
                        } else {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                ForEach(featuredProducts) { product in
                                    ProductCard(product: product)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationBarHidden(true)
            .onAppear {
                loadFeaturedProducts()
            }
        }
    }
    
    private func loadFeaturedProducts() {
        ProductService.shared.getProducts { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let products):
                    self.featuredProducts = Array(products.prefix(4))
                case .failure(let error):
                    print("Error loading featured products: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
