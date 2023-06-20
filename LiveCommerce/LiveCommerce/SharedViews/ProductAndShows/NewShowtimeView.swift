//
//  NewShowtimeView.swift
//  LiveCommerce
//
//  Created by Max Cobb on 08/03/2023.
//

import SwiftUI
import PhotosUI

struct NewShowtimeView: View {
    @Binding var showNewItemView: Bool
    @State var name = ""
    @State var showtimeDate = Date()
    @State var images: [PhotosPickerItem] = []
    @State private var selectedProducts: [String] = []
    @State var productOptions: [(name: String, id: String)]

    var storeId: String
    let addNewItem: (LiveShow) -> Void

    private func binding(for productId: String) -> Binding<Bool> {
        Binding<Bool>(
            get: { selectedProducts.contains(productId) },
            set: { isSelected in
                if isSelected {
                    selectedProducts.append(productId)
                } else {
                    if let index = selectedProducts.firstIndex(of: productId) {
                        selectedProducts.remove(at: index)
                    }
                }
            }
        )
    }

    var body: some View {
        NavigationView {
            Form(content: {
                Section {
                    TextField("Name", text: $name)
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
                    DatePicker(
                        "Show Date", selection: $showtimeDate,
                        in: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!...,
                        displayedComponents: [.date, .hourAndMinute]
                    ).onAppear {
                        UIDatePicker.appearance().minuteInterval = 15
                    }
                }

                Section(header: Text("Products for this Event")) {
                    List(productOptions, id: \.id) { product in
                        Toggle(product.name, isOn: binding(for: product.id))
                    }
                }

                Section {
                    Button(action: {
                        Task {
                            let img = try? await images.first?.loadTransferable(type: Data.self)
                            let imgURL = img == nil ? nil : try? await FirebaseConnect.shared.uploadImage(image: img!)

                            let newProduct = LiveShow(image: imgURL, name: name, id: UUID().uuidString, liveShowtime: showtimeDate, storeId: storeId, products: self.selectedProducts)

                            self.addNewItem(newProduct)
                        }
                    }) {
                        Text("Save")
                    }.disabled(name.isEmpty)

                    Button(action: {
                        showNewItemView = false
                    }) {
                        Text("Cancel")
                    }
                }
            })
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
