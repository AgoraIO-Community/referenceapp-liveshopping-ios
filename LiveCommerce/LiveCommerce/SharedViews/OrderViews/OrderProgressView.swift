//
//  OrderProgressView.swift
//  LiveCommerce
//
//  Created by Max Cobb on 11/04/2023.
//

import SwiftUI

struct OrderProgressView: View {
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    @State var progress: OrderProgress
    var body: some View {
        switch progress {
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
    }
}

struct OrderProgressView_Previews: PreviewProvider {
    static var previews: some View {
        OrderProgressView(progress: .delivered(.now))
    }
}
