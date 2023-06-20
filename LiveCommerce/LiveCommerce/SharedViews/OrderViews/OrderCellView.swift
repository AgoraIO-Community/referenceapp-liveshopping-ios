//
//  OrderCellView.swift
//  LiveCommerce
//
//  Created by Max Cobb on 11/04/2023.
//

import SwiftUI

enum OrderProgress: Codable {
    case placed(Date)
    case shipped(Date)
    case delivered(Date)
}

struct Order: Identifiable, Codable {
    let datePlaced: Date
    /// A unique identifier for the order
    var id: String
    let productName: String
    var progress: OrderProgress
}


struct OrderCellView: View {
    /// state to hold the array of orders/
    @State var order: Order
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    let canEdit: Bool
    var stateCanBack: Bool {
        switch order.progress {
        case .placed: return false
        default: return true
        }
    }
    var stateCanForward: Bool {
        switch order.progress {
        case .delivered: return false
        default: return true
        }
    }

    var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(order.productName)
                    Text(dateFormatter.string(from: order.datePlaced)).font(.footnote)
                }
                Spacer()
                if canEdit {
                    Button {
                        switch order.progress {
                        case .shipped:
                            self.order.progress = .placed(.now)
                        case .delivered:
                            self.order.progress = .shipped(.now)
                        default: break
                        }
                        self.updateOrderObject()
                    } label: {
                        Image(systemName: "chevron.left")
                    }.buttonStyle(PlainButtonStyle())
                        .disabled(!stateCanBack)
                }
                switch order.progress {
                case .placed:
                    VStack(alignment: .trailing) {
                        Text("Order Placed")
                        Text("Awaiting Shipment").font(.footnote)
                    }
                case .shipped:
                    VStack(alignment: .trailing) {
                        Text("Delivering")
                    }
                case .delivered(let date):
                    VStack(alignment: .trailing) {
                        Text("Delivered")
                        Text(dateFormatter.string(from: date))
                            .font(.footnote)
                    }.foregroundColor(.green)
                }
                if canEdit {
                    Button {
                        switch order.progress {
                        case .placed:
                            self.order.progress = .shipped(.now)
                        case .shipped:
                            self.order.progress = .delivered(.now)
                        default: break
                        }
                        self.updateOrderObject()
                    } label: {
                        Image(systemName: "chevron.right")
                    }.buttonStyle(PlainButtonStyle())
                        .disabled(!stateCanForward)
                }
            }
    }

    func updateOrderObject() {
        Task {
            try await FirebaseConnect.shared.uploadDatabaseObject(self.order, in: "orders")
        }
    }
}

struct OrderCellView_Previews: PreviewProvider {
    static var previews: some View {
        OrderCellView(order: Order(datePlaced: .now, id: "123", productName: "iPhone 14 Pro", progress: .placed(.now)), canEdit: true)
    }
}
