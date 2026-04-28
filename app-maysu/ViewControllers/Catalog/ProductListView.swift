//
//  ProductListView.swift
//  app-maysu
//
//  Created by XCODE on 28/04/26.
//

import SwiftUI

struct ProductListView: View {
    let products: [Product] = Product.sampleData
    
    var body: some View {
        NavigationView {
            List(products) { product in
                HStack {
                    Image(systemName: "cart.fill") // Placeholder for image
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.green)
                        .padding(.trailing, 10)
                    
                    VStack(alignment: .leading) {
                        Text(product.name)
                            .font(.headline)
                        Text(product.category)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("$\(product.price, specifier: "%.2f")")
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Catálogo MaySu")
        }
    }
}

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView()
    }
}
