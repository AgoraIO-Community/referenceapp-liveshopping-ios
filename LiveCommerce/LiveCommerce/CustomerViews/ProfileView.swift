//
//  ProfileView.swift
//  LiveCommerce
//
//  Created by Max Cobb on 16/01/2023.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var storeData: StoreData
    @State var displayName: String = ""
    @State var profileImage: String?
    var body: some View {
        VStack {
            if storeData.profile != nil {
                FirebaseAsyncImage(bucketLocation: $profileImage)
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
                    .padding(.bottom, 20)
                AppTextField(placeholder: "", text: $displayName, pretext: "Username")
                    .font(.title)
                    .padding(.bottom, 20)
                Button {
                    // save
                    Task {
                        try? await FirebaseConnect.shared.uploadDatabaseObject(Profile(name: displayName, id: storeData.userAccount, image: profileImage), in: "users")
                    }
                } label: {
                    Text("Save")
                }.disabled(displayName.isEmpty || displayName == storeData.profile?.name)

                Spacer()
            } else {
                VStack {
                    Spacer()
                    Image(systemName: "questionmark.square.dashed")
                    Text("Could not find profile")
                    Spacer()
                }
            }
        }
        .navigationBarTitle("Profile")
        .onAppear {
            self.displayName = storeData.profile?.name ?? ""
            self.profileImage = storeData.profile?.image
        }
    }
}

/**
    A struct representing the user's profile information, which has the following properties:
    - name: A string representing the user's name
    - email: A string representing the user's email address
    - image: A string representing the name of the image file for the user's profile picture
*/
struct Profile: Codable, Identifiable {
    var name: String
    var id: String
    var image: String?
}
