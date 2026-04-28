//
//  ProductListView.swift
//  app-maysu
//
//  Created by XCODE on 28/04/26.
//

import SwiftUI

struct ProductListView: View {
    @State private var products: [Product] = []
    @State private var searchText = ""
    @State private var selectedCategory: String = "Todos"
    @State private var isLoading = true
    
    let categories = ["Todos", "Frutas y Verduras", "Lácteos", "Abarrotes", "Bebidas", "Limpieza"]
    
    var filteredProducts: [Product] {
        products.filter { product in
            let matchesSearch = searchText.isEmpty || product.name.lowercased().contains(searchText.lowercased())
            let matchesCategory = selectedCategory == "Todos" || product.category == selectedCategory
            return matchesSearch && matchesCategory
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Barra de Búsqueda
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Buscar productos...", text: $searchText)
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Selector de Categoría
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                Text(category)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == category ? Color.green : Color(.systemGray6))
                                    .foregroundColor(selectedCategory == category ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                
                if isLoading {
                    Spacer()
                    ProgressView("Cargando productos...")
                        .accentColor(.green)
                    Spacer()
                } else if products.isEmpty {
                    Spacer()
                    VStack(spacing: 15) {
                        Image(systemName: "cart.badge.questionmark")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No se encontraron productos")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    // Lista de Productos
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(filteredProducts) { product in
                                ProductCard(product: product)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Catálogo")
            .onAppear {
                loadProducts()
            }
        }
    }
    
    func loadProducts() {
        FirestoreService.shared.fetchProducts { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedProducts):
                    self.products = fetchedProducts
                case .failure(let error):
                    print("Error al cargar productos: \(error.localizedDescription)")
                    // En caso de error, podríamos usar datos de muestra como respaldo
                    self.products = Product.sampleData
                }
            }
        }
    }
}

struct ProductCard: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.systemGray6))
                    .frame(height: 150)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray.opacity(0.3))
                    )
                
                Button(action: {
                    CartManager.shared.addToCart(product: product)
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

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView()
    }
}
