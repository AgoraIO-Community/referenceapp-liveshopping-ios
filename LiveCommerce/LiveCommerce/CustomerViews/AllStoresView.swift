//
//  AllStoresView.swift
//  LiveCommerce
//
//  Created by Max Cobb on 16/01/2023.
//

import SwiftUI

struct AllStoresView: View {
    @ObservedObject var storeData: StoreData
    var body: some View {
        NavigationView {
            List {
                ForEach(storeData.stores, id: \.id) { store in
                    NavigationLink(destination: StoreView(storeData: storeData, storeId: store.id, productClicked: { _ in
                        // TODO: Add prodcut clicked bit
                    })) {
                        StoreRow(store: store)
                    }
                }
            }
            .navigationBarTitle("All Stores")
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct StoreRow: View {
    var store: Store
    var body: some View {
        HStack {
            Image(store.image)
                .resizable()
                .frame(width: 50, height: 50)
            Text(store.name)
            Spacer()
            Text(store.location)
        }
    }
}
