//
//  MerchantView.swift
//  LiveCommerce
//
//  Created by Max Cobb on 17/02/2023.
//

import SwiftUI

struct MerchantView: View {
    @ObservedObject var storeData: StoreData
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            if let storeId = storeData.myStore?.id {
                StoreView(storeData: storeData, storeId: storeId, productClicked: { _ in
                    selectedTab = 1
                }).tabItem {
                    Image(systemName: "building.fill")
                    Text("Storefront")
                }.tag(0)
                GoLiveView(storeData: storeData)
                    .tabItem {
                        Image(systemName: "video")
                        Text("Go Live")
                    }.tag(1)
                OrderListView(viewType: .store(id: storeId))
                    .tabItem {
                        Image(systemName: "list.bullet.clipboard")
                        Text("Orders")
                    }.tag(2)
            }
        }
    }
}

struct ShopOrders: View {
    var body: some View {
        Text("List of placed orders and their status")
    }
}
