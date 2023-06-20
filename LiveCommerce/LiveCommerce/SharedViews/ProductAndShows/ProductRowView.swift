//
//  ProductRowView.swift
//  LiveCommerce
//
//  Created by Max Cobb on 08/03/2023.
//

import SwiftUI

struct ProductRow: View {
    let isMyProduct: Bool
    var product: Product
    func getForegroundColor(from name: String) -> Color {
        let nameLC = name.lowercased()
        if nameLC.contains("red") {
            return .red
        } else if nameLC.contains("blue") {
            return .blue
        } else if nameLC.contains("yellow") {
            return .yellow
        } else if nameLC.contains("purple") {
            return .purple
        }
        return .accentColor
    }
    var body: some View {
        HStack {
//            Image(product.image)
//                .resizable()
//                .frame(width: 50, height: 50)
            Image(systemName: "tshirt.fill")
                .resizable()
                .clipShape(Circle())
                .frame(width: 50, height: 50)
                .foregroundColor(self.getForegroundColor(from: product.name))
            VStack(alignment: .leading) {
                Text(product.name)
                Text("Price: \(product.price.formatted(.currency(code: "USD")))")
            }
        }.multilineTextAlignment(.trailing)
    }
}
