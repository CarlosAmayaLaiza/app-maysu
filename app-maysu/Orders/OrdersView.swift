//
//  OrdersView.swift
//  app-maysu
//
//  Created by XCODE on 28/04/26.
//

import SwiftUI

struct OrdersView: View {
    @State private var orders: [Order] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            List {
                if let error = errorMessage {
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Error", systemImage: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.caption)
                            Button("Reintentar") {
                                loadOrders()
                            }
                            .buttonStyle(.bordered)
                            .tint(.green)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView("Cargando pedidos...")
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                } else if orders.isEmpty {
                    VStack(alignment: .center, spacing: 20) {
                        Spacer()
                        Image(systemName: "clock.arrow.circlepath")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                        
                        Text("No tienes órdenes recientes")
                            .font(.headline)
                        
                        Text("Tus pedidos aparecerán aquí una vez que realices una compra.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(orders) { order in
                        NavigationLink(destination: OrderDetailView(order: order)) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Orden #\(order.id.prefix(8).uppercased())")
                                        .fontWeight(.bold)
                                    Spacer()
                                    Text(order.status)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(statusColor(order.status).opacity(0.2))
                                        .foregroundColor(statusColor(order.status))
                                        .cornerRadius(8)
                                }
                                
                                Text("Fecha: \(order.date, style: .date)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Text("\(order.items.count) productos")
                                        .font(.subheadline)
                                    Spacer()
                                    Text("Total: $\(order.total, specifier: "%.2f")")
                                        .fontWeight(.semibold)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Mis Órdenes")
            .onAppear {
                loadOrders()
            }
        }
    }
    
    private func loadOrders() {
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
    
    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "entregado": return .green
        case "pendiente": return .orange
        case "cancelado": return .red
        default: return .blue
        }
    }
}

struct OrdersView_Previews: PreviewProvider {
    static var previews: some View {
        OrdersView()
    }
}
