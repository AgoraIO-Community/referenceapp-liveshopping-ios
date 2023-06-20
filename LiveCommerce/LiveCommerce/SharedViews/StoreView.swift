//
//  StoreView.swift
//  LiveCommerce
//
//  Created by Max Cobb on 20/03/2023.
//

import SwiftUI

struct StoreView: View {
    var isMyStore: Bool {
        guard let storeId, let myStoreId = self.storeData.myStore?.id else {
            return false
        }
        return storeId == myStoreId
    }
    @ObservedObject var storeData: StoreData
    var storeId: String?
    var store: Store? {
        self.storeData.stores.first { $0.id == storeId }
    }
    @State var liveShows: [LiveShow] = []
    @State var products: [Product] = []
    @State var showPreviousShows = false
    var upcomingShows: [LiveShow] {
        if !self.showShows { return [] }
        return liveShows.filter { $0.liveShowtime >= Date().addingTimeInterval(-60 * 60 * 2) }.sorted { $0.liveShowtime < $1.liveShowtime }
    }
    var previousShows: [LiveShow] {
        if !self.showShows { return [] }
        return liveShows.filter { $0.liveShowtime < Date().addingTimeInterval(-60 * 60 * 2) }.sorted { $0.liveShowtime < $1.liveShowtime }
    }
    var isOwner: Bool {
        self.storeData.myStore != nil && self.storeData.myStore!.id == self.storeId
    }
    @State var isEditing = false
    @State var isShowingNewItemView = false
    @State var isShowingNewShowtimeView = false
    @State var showDeleteAlert = false
    @State var productToDelete: Product?
    @State var showShows = false

    var productClicked: (LiveShow) -> Void
    var body: some View {
        NavigationView {
            HStack {
                if let store = self.store {
                    VStack {
                        Image(systemName: "building.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        Text("\(store.name), \(store.location)")
                            .font(.title3)
                        Spacer()
                        Text(store.description)
                            .padding(.top, 8)
                            .font(.subheadline)
                        List {
                            ForEach(upcomingShows) { show in
                                Button {
                                    self.productClicked(show)
                                } label: {
                                    ShowtimeRow(isMyShow: self.isMyStore, liveShow: show)
                                }
                            }.onDelete { indices in
                                let itemsToDelete = indices.map { upcomingShows[$0] }

                                for item in itemsToDelete {
                                    if let index = self.liveShows.firstIndex(of: item) {
                                        self.liveShows.remove(at: index)
                                    }
                                }
                                let deleteIds = itemsToDelete.map { $0.id }
                                Task {
                                    await FirebaseConnect.shared.deleteStoreSub(in: store.id, ids: deleteIds, childPath: "shows")
                                }
                            }
                            if self.showShows {
                                Button(action: {
                                    isShowingNewShowtimeView = true
                                }) {
                                    Text("Add New Show")
                                }
                            }

                            Section {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 16) {
                                        ForEach(products) { product in
                                            Button(action: {
                                                // Handle product tap
                                            }) {
                                                ProductCardView(product: product, isOwner: self.isOwner, deleteProduct: { product in
                                                    self.productToDelete = product
                                                    showDeleteAlert = true
                                                })
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            } header: {
                                HStack {
                                    Text("All Products")
                                        .font(.headline)
                                    Spacer()
                                    Button {
                                        self.isShowingNewItemView = true
                                    } label: {
                                        Image(systemName: "plus.app")
                                    }

                                }
                            }

                            if !self.previousShows.isEmpty {
                                Section(header:
                                            HStack {
                                    Text("Previous Shows")
                                        .font(.headline)
                                    Spacer()
                                    Button(action: { self.showPreviousShows.toggle() }) {
                                        Image(systemName: self.showPreviousShows ? "chevron.up" : "chevron.down")
                                            .resizable()
                                            .frame(width: 18, height: 18)
                                    }
                                }
                                ) {
                                    if showPreviousShows {
                                        ForEach(previousShows) { show in
                                            ShowtimeRow(isMyShow: self.isMyStore, liveShow: show)
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                        .navigationBarItems(trailing: EditButton())
                        .environment(\.editMode, .constant((self.isMyStore && self.isEditing) ? EditMode.active : EditMode.inactive))
                    }
                }
                Spacer()
            }.sheet(isPresented: $isShowingNewItemView) {
                NewProductView(
                    showNewItemView: $isShowingNewItemView, storeId: self.storeId!,
                    addNewItem: { newProduct in
                        self.products.append(newProduct)
                        isShowingNewItemView = false
                        Task {
                            try? await FirebaseConnect.shared.uploadNewArrayVal(newShow: newProduct, in: "products", store: storeId!)
                        }
                    }
                )
            }.sheet(isPresented: $isShowingNewShowtimeView, content: {
                NewShowtimeView(
                    showNewItemView: $isShowingNewShowtimeView,
                    productOptions: self.products.map { (name: $0.name, id: $0.id) },
                    storeId: self.storeId!
                ) { newShow in
                    self.liveShows.append(newShow)
                    self.isShowingNewShowtimeView = false
                    Task {
                        try? await FirebaseConnect.shared.uploadNewArrayVal(newShow: newShow, in: "shows", store: newShow.storeId)
                    }
                }
            }).alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Delete Product"),
                    message: Text("Are you sure you want to delete this product?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let productToDelete {
                            delete(product: productToDelete)
                        }
                    },
                    secondaryButton: .cancel(Text("Cancel"))
                )
            }.onAppear {
                Task {
                    await fetchShows()
                    await fetchProducts()
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    func delete(product: Product) {
        guard let storeId else { return }
        Task {
            await FirebaseConnect.shared.deleteStoreSub(in: storeId, ids: [product.id], childPath: "products")
        }
        self.products.removeAll { $0.id == product.id }
        self.store?.products?.removeAll { $0 == product.id }

    }
    func fetchShows() async {
        guard let store, let showStrings = store.shows else { return }
        let shows: [LiveShow] = await FirebaseConnect.shared.getObjects(from: "shows", ids: showStrings)

        DispatchQueue.main.async {
            self.liveShows = shows
        }
    }

    func fetchProducts() async {
        guard let store, self.products.isEmpty, let prodStrings = store.products else { return }
        let products: [Product] = await FirebaseConnect.shared.getObjects(from: "products", ids: prodStrings)

        DispatchQueue.main.async {
            self.products = products
        }
    }
}
struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        StoreView(storeData: StoreData(), productClicked: { _ in })
    }
}
