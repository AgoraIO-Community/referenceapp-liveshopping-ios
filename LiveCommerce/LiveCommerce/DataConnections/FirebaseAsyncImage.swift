//
//  FirebaseAsyncImage.swift
//  LiveCommerce
//
//  Created by Max Cobb on 16/03/2023.
//

import SwiftUI

struct FirebaseAsyncImage: View {
    @Binding var bucketLocation: String?
    let systemPlaceholder: String = "questionmark.folder"
    @State private var showPlaceholder = false
    @State private var imageURL: URL?

    var body: some View {
        Group {
            if showPlaceholder {
                Image(systemName: systemPlaceholder)
                    .resizable().aspectRatio(contentMode: .fit)
            } else if let imageURL, !showPlaceholder {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    case .failure(let err):
                        EmptyView().onAppear {
                            print("FirebaseAsyncImage: Error downloading Image: \(err.localizedDescription)")
                            self.showPlaceholder = true
                        }
                    default: ProgressView()
                    }
                }
            } else {
                ProgressView()
            }
        }.onAppear { getImageURL() }
        .onChange(of: bucketLocation) { _ in
            imageURL = nil
            getImageURL()
        }
    }

    private func getImageURL() {
        guard let bucketLocation else {
            showPlaceholder = true
            return
        }
        showPlaceholder = false
        let storageRef = FirebaseConnect.shared.storage.reference()
        let imageRef = storageRef.child(bucketLocation)

        imageRef.downloadURL { url, error in
            if let error {
                print("FirebaseAsyncImage: Error fetching download URL: \(error)")
                self.showPlaceholder = true
            } else if let url {
                self.imageURL = url
            }
        }
    }
}

struct FirebaseAsyncImage_Previews: PreviewProvider {
    static var previews: some View {
        FirebaseAsyncImage(bucketLocation: .constant("images/D1522669-9134-4D0F-A044-322D8F89B5BD"))
    }
}
