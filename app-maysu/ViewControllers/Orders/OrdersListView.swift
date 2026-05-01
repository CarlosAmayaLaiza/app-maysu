//
//  OrdersListView.swift
//  app-maysu
//
//  Created by XCODE on 28/04/26.
//

import SwiftUI

struct OrdersListView: View {
    @State private var orders: [Order] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        List {
            if let error = errorMessage {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Error al cargar pedidos", systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.headline)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button("Reintentar") {
                            loadOrders()
                        }
                        .padding(.vertical, 5)
                        .buttonStyle(.bordered)
                        .tint(.green)
                    }
                    .padding(.vertical, 10)
                }
            }
            
            if isLoading {
                HStack {
                    Spacer()
                    ProgressView("Cargando tus pedidos...")
                    Spacer()
                }
                .listRowBackground(Color.clear)
            } else if orders.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "bag.badge.questionmark")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("Aún no tienes pedidos")
                        .font(.headline)
                    Text("Tus pedidos aparecerán aquí una vez que realices una compra.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 40)
                .listRowBackground(Color.clear)
            } else {
                ForEach(orders) { order in
                    NavigationLink(destination: OrderDetailView(order: order)) {
                        OrderRow(order: order)
                    }
                }
            }
        }
        .navigationTitle("Mis Pedidos")
        .listStyle(InsetGroupedListStyle())
        .onAppear {
            loadOrders()
        }
        .refreshable {
            loadOrders()
        }
    }
    
    func loadOrders() {
        isLoading = true
        errorMessage = nil
        OrderService.shared.getOrderHistory { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedOrders):
                    self.orders = fetchedOrders
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct OrderRow: View {
    let order: Order
    
    private var statusInfo: (text: String, color: Color) {
        let info = OrderService.shared.getStatusInfo(status: order.status)
        let color: Color
        switch info.colorName {
        case "green": color = .green
        case "orange": color = .orange
        case "blue": color = .blue
        case "red": color = .red
        default: color = .gray
        }
        return (info.text, color)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Pedido #\(order.id.prefix(6).uppercased())")
                    .fontWeight(.bold)
                Spacer()
                Text(statusInfo.text)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusInfo.color.opacity(0.1))
                    .foregroundColor(statusInfo.color)
                    .cornerRadius(8)
            }
            
            Text(order.date, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
            
            HStack {
                Text("\(order.itemCount) productos")
                    .font(.subheadline)
                Spacer()
                Text("Total: $\(order.total, specifier: "%.2f")")
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 5)
    }
}

struct OrdersListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OrdersListView()
        }
    }
}
