//
//  ContentView.swift
//  LiveCommerce
//
//  Created by Max Cobb on 16/01/2023.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab = 0
//    @ObservedObject var storeData = StoreData()

    var body: some View {
        LoginView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
