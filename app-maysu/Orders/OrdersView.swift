//
//  OrdersView.swift
//  app-maysu
//
//  Created by XCODE on 28/04/26.
//

import SwiftUI

struct OrdersView: View {
    @State private var orders: [Order] = [] // Assuming Order exists in Models
    
    var body: some View {
        NavigationView {
            List {
                if orders.isEmpty {
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
                                Text("\(order.itemCount) productos")
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
            .navigationTitle("Mis Órdenes")
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
