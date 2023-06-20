//
//  NewProductView.swift
//  LiveCommerce
//
//  Created by Max Cobb on 08/03/2023.
//

import SwiftUI
import PhotosUI

struct NewProductView: View {
    @Binding var showNewItemView: Bool
    @State var name = ""
    @State var price = ""
    @State var numberOfItems: Int = 0
    @State var images: [PhotosPickerItem] = []
    @State var showtimeDate = Date()
    @State var taskInProgress: Bool = false

    var storeId: String
    let addNewItem: (Product) -> Void

    var body: some View {
        NavigationView {
            ZStack {
                Form(content: {
                    Section {
                        TextField("Name", text: $name)
                        TextField("Price", text: $price)
                            .keyboardType(.decimalPad)
                        PhotosPicker(selection: $images, maxSelectionCount: 1, matching: .images) {
                            HStack {
                                if $images.isEmpty {
                                    Text("Select a Photo")
                                    Image(systemName: "photo")
                                } else {
                                    Text("Change Photo")
                                    Image(systemName: "photo.on.rectangle.angled")
                                }
                                Spacer()
                            }
                        }
                        Stepper("Number of Items: \(numberOfItems)", value: $numberOfItems, in: 1...20)
                    }

                    Section {
                        Button(action: {
                            guard let price = Double(price) else {
                                return
                            }

                            Task {
                                let img = try? await images.first?.loadTransferable(type: Data.self)
                                let imgURL = img == nil ? nil : try? await FirebaseConnect.shared.uploadImage(image: img!)

                                let newProduct = Product(
                                    image: imgURL ?? "",
                                    name: name,
                                    price: price,
                                    stock: numberOfItems,
                                    id: UUID().uuidString
                                )

                                self.addNewItem(newProduct)
                            }
                        }) {
                            Text("Save")
                        }.disabled(Double(price) == nil || name.isEmpty || (numberOfItems == 0))

                        Button(action: {
                            showNewItemView = false
                        }) {
                            Text("Cancel")
                        }
                    }
                })
                if self.taskInProgress { ProgressView() }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
