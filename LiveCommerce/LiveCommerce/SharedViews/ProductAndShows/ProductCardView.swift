//
//  ProductCardView.swift
//  LiveCommerce
//
//  Created by Max Cobb on 07/03/2023.
//

import SwiftUI

struct ProductCardView: View {
    let product: Product

    var isOwner: Bool = false
    var deleteProduct: ((Product) -> Void)? // callback to delete product
    @State private var showAlert = false
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                FirebaseAsyncImage(bucketLocation: .constant(product.image))
                    .frame(width: 160, height: 120)
                    .overlay(alignment: .topTrailing) {
                        if isOwner, let deleteProduct {
                            Button {
                                deleteProduct(product)
                            } label: {
                                Image(systemName: "minus.square")
                                    .tint(.red)
                            }.padding()
                        }
                    }

                GroupBox {
                    Text(product.name)
                        .font(.headline)

                    HStack {
                        Text("$\(product.price, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("\(product.stock) available")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }.multilineTextAlignment(.leading).frame(width: 160)
            }
        }
        .padding()
        .frame(width: 160, height: 180)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct ProductCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProductCardView(product: Product(image: "images/D1522669-9134-4D0F-A044-322D8F89B5BD", name: "Example", price: 10.99, stock: 5, id: "example-product"), isOwner: false) { _ in
            print("deletie")
        }
    }
}
