//
//  ChooseItemView.swift
//  LiveCommerce
//
//  Created by Max Cobb on 15/03/2023.
//

import SwiftUI

struct ChooseItemView: View {
    var store: Store
    @State var chosenObject: Product?
    @State var products: [Product]?
    var storeProducts: [String] {
        self.store.products ?? []
    }
    var productUpdated: (String?) -> Void
    @State var isChoosingObject = false
    var body: some View {
        if isChoosingObject {
            if let products {
                if products.isEmpty {
                    Text("Product Fetch Failed")
                        .padding()
                        .background(.tertiary)
                        .cornerRadius(5)
                } else {
                    VStack {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(products) { product in
                                    Button(action: {
                                        withAnimation {
                                            // Handle product tap
                                            self.chosenObject = product
                                            self.isChoosingObject = false
                                            self.productUpdated(product.id)
                                        }
                                    }) {
                                        ProductCardView(product: product, isOwner: false)
                                    }
                                }
                            }.frame(height: 190)
                            .padding(.horizontal)
                        }
                        Button {
                            withAnimation {
                                self.isChoosingObject = false
                            }
                        } label: {
                            Text("Cancel")
                                .tint(.red)
                                .padding(10)
                        }.background(.tertiary).cornerRadius(5).padding()
                    }
                }
            } else {
                EmptyView()
            }
        } else if let chosenObject {
            VStack {
                Group {
                    Text("\(chosenObject.name) ($\(chosenObject.price, specifier: "%.2f"))")
                        .padding(10)
                }.background(.background)
                    .cornerRadius(5)
                    .overlay(RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.primary.opacity(0.2), lineWidth: 1))
                    .padding([.leading, .trailing])

                HStack {
                    Button {
                        withAnimation {
                            isChoosingObject = true
                        }
                    } label: {
                        Text("Change")
                            .padding(10)
                    }.background(.tertiary).cornerRadius(5).padding([.bottom])
                    Button {
                        withAnimation {
                            self.chosenObject = nil
                        }
                        self.productUpdated(nil)
                    } label: {
                        Text("Clear")
                            .tint(.red)
                            .padding(10)
                    }.background(.tertiary).cornerRadius(5).padding([.bottom])
                }
            }
        } else if !storeProducts.isEmpty {
            Button {
                guard !storeProducts.isEmpty else { return }
                Task {
                    if self.products == nil {
                        let products: [Product] = await FirebaseConnect.shared.getObjects(from: "products", ids: storeProducts)

                        DispatchQueue.main.async {
                            withAnimation {
                                self.products = products
                            }
                        }
                    }
                    isChoosingObject = true
                }
            } label: {
                Text("Choose Product")
                    .padding(10)
            }
            .background(.tertiary)
            .cornerRadius(5)
            .padding()
        }
    }
}

struct ChooseItemView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            ChooseItemView(store: Store(name: "example", category: .electronics, image: "", id: "123", location: "", description: "", products: [
                "375B7CB3-9926-4D1F-93EE-CDD482CC9327",
                "0E2FE4AA-A96C-44A3-9AFA-0FE1891164A4",
                "C065B888-36E1-4444-900C-3EC39AB47A78"
            ])) { _ in }
        }
    }
}
