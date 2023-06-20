//
//  SettingsView.swift
//  LiveCommerce
//
//  Created by Max Cobb on 16/01/2023.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var storeData: StoreData
    @State var notificationsEnabled = false
    var body: some View {
        Form {
            Section(header: Text("Notifications")) {
                Toggle(isOn: $notificationsEnabled) {
                    Text("Enable notifications")
                }
            }
            Section(header: Text("Account")) {
                NavigationLink(destination: ProfileView(storeData: storeData)) {
                    Text("View profile")
                }
//                Button(action: logout) {
//                    Text("Logout")
//                }
            }
        }
    }
}
