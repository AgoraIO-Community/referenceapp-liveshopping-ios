//
//  OrderListView.swift
//  LiveCommerce
//
//  Created by Max Cobb on 11/04/2023.
//

import SwiftUI

enum OrderListViewType {
    case store(id: String)
    case user(id: String)
}

struct OrderListView: View {
    /// enum that specifies whether to display store or user orders/
    let viewType: OrderListViewType
    /// state to hold the array of orders/
    @State private var orders: [Order]? = []
    @State var selectedOrder: Order?
    @State var showPopup = false
    
    var isStoreList: Bool {
        switch viewType {
        case .store:
            return true
        default:
            return false
        }
    }
    
    var body: some View {
        VStack {
            Text("Orders").font(.title)
            if isStoreList {
                Text("Tap to progress order").font(.footnote)
            }
            Group {
                if orders == nil {
                    ProgressView()
                } else if orders!.isEmpty {
                    Text("No orders found")
                } else {
                    List(orders!) { order in
                        OrderCellView(order: order, canEdit: isStoreList)
                    }
                }
            }.onAppear {
                Task {
                    self.orders = (await fetchOrders()).sorted { $0.datePlaced > $1.datePlaced }
                }
            }
        }
        
    }
    private func fetchOrders() async -> [Order] {
        var ordersPath: String
        switch viewType {
        case .store(let id):
            // make API call to fetch store orders based on id
            ordersPath = "stores/\(id)/orders"
        case .user(let id):
            // make API call to fetch user orders based on id
            ordersPath = "users/\(id)/orders"
        }
        let orderIds = await FirebaseConnect.shared.getStrings(from: ordersPath)
        return await FirebaseConnect.shared.getObjects(from: "orders", ids: orderIds)
    }
}

struct OrderListView_Previews: PreviewProvider {
    static var previews: some View {
        OrderListView(viewType: .store(id: ""))
    }
}
