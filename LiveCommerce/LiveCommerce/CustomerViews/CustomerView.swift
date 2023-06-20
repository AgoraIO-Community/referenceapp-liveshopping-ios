//
//  CustomerView.swift
//  LiveCommerce
//
//  Created by Max Cobb on 06/02/2023.
//

import SwiftUI

struct CustomerView: View {
    @State var selectedTab = 0
    @ObservedObject var storeData: StoreData

    var body: some View {
        TabView(selection: $selectedTab) {
            OnlineStoresView(storeData: storeData)
                .tabItem {
                    Image(systemName: "video.fill")
                    Text("Online Stores")
                }
                .tag(0)
            AllStoresView(storeData: storeData)
                .tabItem {
                    Image(systemName: "building.2")
                    Text("All Stores")
                }
                .tag(1)
            OrderListView(viewType: .user(id: storeData.userAccount))
                .tabItem {
                    Image(systemName: "shippingbox")
                    Text("Orders")
                }
                .tag(2)
            ProfileView(storeData: storeData)
                .tabItem {
                    Image(systemName: "person")
                    Text("Settings")
                }
                .tag(3)
        }
    }
}
