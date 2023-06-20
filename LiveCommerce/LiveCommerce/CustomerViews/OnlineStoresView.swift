//
//  OnlineStoresView.swift
//  LiveCommerce
//
//  Created by Max Cobb on 16/01/2023.
//

import SwiftUI
import SnapToScroll

struct OnlineStoresView: View {
    @ObservedObject var storeData: StoreData
    @State private var startOffset: CGFloat?
    @State private var offset: CGFloat = 0
    @State private var isScrolling = false
    @State var confettiTrigger = 0
    @State var activeProduct: Product?
    @State var storesOnline: [(Store, RtmClient.StoreStatus)] = [
        (Store(name: "example", category: .bookstore, image: "", id: "bookstore", location: "wahoo", description: "doope", products: []), RtmClient.StoreStatus(isLive: true, isOnline: true, storeId: "test", memberId: "bookstore", showingProduct: "C065B888-36E1-4444-900C-3EC39AB47A78")),
        (Store(name: "example2", category: .bookstore, image: "", id: "bookstore2", location: "wahoo", description: "doope", products: []), RtmClient.StoreStatus(isLive: true, isOnline: true, storeId: "test2", memberId: "bookstore2", showingProduct: "C065B888-36E1-4444-900C-3EC39AB47A78"))
    ]
    @State var storeIndex: Int?
    //        self.storeData.stores.compactMap {
    //            if let storeData = self.storeData.storeOnlineData[$0.id], storeData.isLive {
    //                return ($0, storeData)
    //            }
    //            return nil
    //        }
    var body: some View {
            if self.storeData.statusOfLiveStores.isEmpty {
                Text("No stores are live right now.")
            } else {
                HStackSnap(alignment: SnapAlignment.leading(0), content: {
                    // Carousel of views for stores that are currently online
                    ForEach(self.storeData.statusOfLiveStores, id: \.storeId) { (storeStatus) in
                        VStack {
                            StoreLiveFeedView(storeData: storeData, storeStatus: storeStatus, confettiTrigger: $confettiTrigger)
                                .frame(width: UIScreen.main.bounds.width)
                                .snapAlignmentHelper(id: storeStatus.storeId)   // Step 3

                        }
                    }
                }) { event in
                    switch event {
                    case .swipe(let index):
                        self.updateIndex(to: index)
                        break
                    case .didLayout: break
                    }
                }.onAppear { self.updateIndex(to: 0) }
                .confettiCannon(
                    counter: $confettiTrigger, num: 20, rainHeight: 800,
                    openingAngle: .degrees(50), closingAngle: .degrees(130),
                    radius: 400, repetitions: 3, repetitionInterval: 0.15
                )
            }
//            .navigationTitle("Online Stores")
    }

    func updateIndex(to index: Int?) {
        self.storeIndex = index
        // TODO: Connect to Audio
//        self.updateActiveProduct()
    }

    func fetchProduct(id: String) async -> Product? {
        await FirebaseConnect.shared.getObject(
            from: "products", id: id
        )
    }
}

struct OnlineStoresView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            OnlineStoresView(storeData: StoreData())
        }
    }
}
