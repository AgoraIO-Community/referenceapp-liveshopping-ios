//
//  StoreLiveFeedView.swift
//  LiveCommerce
//
//  Created by Max Cobb on 16/01/2023.
//

import Foundation
import SwiftUI
import PhotosUI
import AgoraRtcKit
import ConfettiSwiftUI

struct StoreLiveFeedView: View {
    @ObservedObject var storeData: StoreData
    var storeStatus: RtmClient.StoreStatus
    var localUid: Int { .random(in: 100..<10_000) }
    @Binding var confettiTrigger: Int
    @State var subscribeAudio = false
    @State var selectedProduct: String?
    @State var lastUpdate: Date?
    @State var showBanuba: Bool = false
    @State private var counter: Int = 0
    var body: some View {
        ZStack {
            AgoraView(localUid: localUid, storeData: storeData, channelName: storeStatus.channelName).onAppear {
                self.storeData.storeVideoLookup[self.storeStatus.storeId] = self
                self.selectedProduct = storeStatus.showingProduct
            }.overlay(alignment: .bottom) {
                VStack {
                    Spacer()
                    if showBanuba {
                        BanubaOptionsView(isPresented: $showBanuba, storeId: self.storeStatus.storeId, filterSelectedCallback: self.filterSelected(named:))
                    } else {
                        LiveFeedBuyProductView(productString: self.$selectedProduct, lastUpdate: $lastUpdate, purchasedProduct: purchasedProduct(_:))
                    }
                }.padding()
            }.onChange(of: self.showBanuba) { newValue in
                if newValue {
                    confettiTrigger += 1
                }
            }
        }
    }
    func purchasedProduct(_ product: Product) {
        self.showBanuba = true
        let newOrder = Order(datePlaced: .now, id: UUID().uuidString, productName: product.name, progress: .placed(.now))
        Task {
            try await FirebaseConnect.shared.uploadDatabaseObject(newOrder, in: "orders")
            try await FirebaseConnect.shared.appendDatabaseObject(newOrder.id, to: "users/\(storeData.userAccount)/orders")
            try await FirebaseConnect.shared.appendDatabaseObject(newOrder.id, to: "stores/\(storeStatus.storeId)/orders")
        }
    }
    func filterSelected(named filter: String) {
        Task {
            let sendErr = await self.storeData.sendBanubaFilter(filter, to: storeStatus)
            print("Send msg response: \((sendErr ?? .invalidMessage).rawValue)")
        }
    }
}

class Store: Codable, Identifiable {
    /// A string representing the name of the store
    var name: String
    /// An enum for the store's category
    var category: StoreCategory
    /// A string representing the name of the image file for the store
    var image: String
    /// A unique ID for the store
    var id: String
    /// A string representing the location of the store
    var location: String
    /// A string representing the description of the store
    var description: String
    /// An array of products that the store sells
    var products: [String]? = []
    var shows: [String]?
    init(
        name: String, category: StoreCategory, image: String, id: String,
        location: String, description: String, products: [String], shows: [String] = []
    ) {
        self.name = name
        self.category = category
        self.image = image
        self.id = id
        self.location = location
        self.description = description
        self.products = products
        self.shows = shows
    }
    /// An enumeration of the different categories for stores
    public enum StoreCategory: String, CaseIterable, Codable {
        /// Fashion store for men and women
        case fashion = "Fashion Store"
        /// Electronics store for all your tech needs
        case electronics = "Electronics Store"
        /// Your one-stop shop for groceries
        case grocery = "Grocery Store"
        /// A wide range of home decor items for your home.
        case homeDecor = "Home Decor Store"
        /// Everything you need for your outdoor adventures.
        case outdoorGear = "Outdoor Gear Store"
        /// A wide selection of books for all ages and interests.
        case bookstore = "Bookstore"
    }
}

struct LiveShow: Identifiable, Codable, Equatable {
    /// A string representing the name of the image file for the product
    var image: String?
    /// A string representing the name of the product
    var name: String
    var id: String
    var liveShowtime: Date
    var storeId: String
    var products: [String]?
}

struct Product: Identifiable, Codable, Equatable {
    /// A string representing the name of the image file for the product
    var image: String
    /// A string representing the name of the product
    var name: String
    /// A double representing the price of the product
    var price: Double
    /// An integer representing the number of items available for the product
    var stock: Int
    var id: String
}
