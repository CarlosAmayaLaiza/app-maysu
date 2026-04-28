//
//  OrderDetailView.swift
//  app-maysu
//
//  Created by XCODE on 28/04/26.
//

import SwiftUI

struct OrderDetailView: View {
    let order: Order
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header del Pedido
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Pedido #\(order.id.prefix(8).uppercased())")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Text(order.status)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(statusColor.opacity(0.1))
                            .foregroundColor(statusColor)
                            .cornerRadius(10)
                    }
                    
                    Text(order.date, style: .date)
                        .foregroundColor(.secondary)
                    Text(order.date, style: .time)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                .padding(.horizontal)
                
                // Lista de Productos
                VStack(alignment: .leading, spacing: 15) {
                    Text("Productos")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(order.items) { item in
                        HStack(spacing: 15) {
                            ZStack {
                                if let url = URL(string: item.imageName) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView().scaleEffect(0.5)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 50, height: 50)
                                                .clipped()
                                                .cornerRadius(8)
                                        case .failure(_):
                                            Image(systemName: "bag.fill")
                                                .foregroundColor(.green.opacity(0.3))
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                } else {
                                    Image(systemName: "bag.fill")
                                        .foregroundColor(.green.opacity(0.3))
                                }
                            }
                            .frame(width: 50, height: 50)
                            
                            VStack(alignment: .leading) {
                                Text(item.productName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("\(item.quantity) unidades")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("$\(item.price * Double(item.quantity), specifier: "%.2f")")
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal)
                        
                        Divider().padding(.horizontal)
                    }
                }
                
                // Resumen de Pago
                VStack(spacing: 12) {
                    HStack {
                        Text("Subtotal")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("$\(order.total, specifier: "%.2f")")
                    }
                    
                    HStack {
                        Text("Envío")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Gratis")
                            .foregroundColor(.green)
                            .fontWeight(.bold)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Total")
                            .font(.headline)
                        Spacer()
                        Text("$\(order.total, specifier: "%.2f")")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                .padding(.horizontal)
                
                // Información de Entrega (Simulada)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Información de entrega")
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.green)
                        Text("Entrega en domicilio")
                            .font(.subheadline)
                    }
                    
                    Text("Tiempo estimado: 30-45 min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 30)
                }
                .padding(.horizontal)
                
                Spacer(minLength: 50)
            }
        }
        .navigationTitle("Detalle del Pedido")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var statusColor: Color {
        switch order.status {
        case "Pendiente": return .orange
        case "En camino": return .blue
        case "Entregado": return .green
        case "Cancelado": return .red
        default: return .gray
        }
    }
}
