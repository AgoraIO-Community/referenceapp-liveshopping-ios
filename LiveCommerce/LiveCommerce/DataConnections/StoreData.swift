//
//  StoreData.swift
//  LiveCommerce
//
//  Created by Max Cobb on 16/01/2023.
//

import SwiftUI
import AgoraRtmKit
import Foundation
import AgoraRtcKit

class StoreData: NSObject, ObservableObject, RtmClientDelegate {

    func handleBanubaFilter(_ filter: RtmClient.BanubaFilter, from user: String) async {
        if filter.filterName != "none" {
            // apply the filter
            DispatchQueue.main.async {
                self.banubaFilter = (filter.filterName, filter.buyerDisplay ?? user)
            }
        }
        let _ = try? await FirebaseConnect.shared.decrementStock(of: filter.productId)
        self.myStoreStatus?.lastUpdate = Date()
    }
    override init() {
        super.init()
        Task {
            let stores: [Store] = await FirebaseConnect.shared.getObjects(from: "stores")
            DispatchQueue.main.async {
                self.stores = stores
            }
        }
    }
    var rtm: RtmClient?
    lazy var rtc: AgoraRtcEngineKit = {
        let engine = AgoraRtcEngineKit.sharedEngine(withAppId: AppKeys.agoraKey, delegate: nil)
        engine.enableVideo()
        return engine
    }()
    var myStoreStatus: RtmClient.StoreStatus? {
        didSet {
            _Concurrency.Task { await self.rtm?.sendStoreStatusUpdate(status: self.myStoreStatus) }
        }
    }
    @State var displayName: String = ""

    var loginStatus: LoginType? {
        didSet {
            var usr: String?
            switch loginStatus {
            case .customer(let username, let displayName):
                usr = username
                self.userAccount = username
                Task {
                    self.profile = await FirebaseConnect.shared.getObject(
                        from: "users", id: username
                    )
                    if let profile {
                        self.displayName = profile.name
                    } else {
                        let dName = displayName ?? "user\(Int.random(in: 1000...9999))"
                        let newProfile = Profile(name: dName, id: username)
                        self.profile = newProfile
                        self.displayName = newProfile.name
                        _ = try? await FirebaseConnect.shared.uploadDatabaseObject(newProfile, in: "users")
                    }
                }
            case .merchant(_, let username):
                usr = username
                if let myStore {
                    self.myStoreStatus = RtmClient.StoreStatus(
                        isLive: false, isOnline: true, storeId: myStore.id, memberId: username
                    )
                }
            default: break
            }
            if let usr {
                self.rtm = RtmClient(delegate: self, username: usr)
            }
        }
    }
    @Published var storeOnlineData: [String: RtmClient.StoreStatus] = [:]
    @Published var stores: [Store] = []
    @Published var banubaFilter: (String?, String)?
    var liveFeedLooup: [String: StoreLiveFeedView] = [:]
//    func nextUpcomingShow(for store: Store.StoreCategory) -> Range<Date> {
//        
//    }
    @Published var onlineStoresList: [String] = []
    /// All the statuses in an array of the stores currently broadcasting
    var statusOfLiveStores: [RtmClient.StoreStatus] { // string here is store ids
        self.onlineStoresList.compactMap { self.storeOnlineData[$0] }
    }
    var myStore: Store? {
        switch loginStatus {
        case .merchant(let category, _): return self.stores.first { $0.category == category }
        default: return nil
        }
    }
    enum LoginType {
        case customer(username: String, displayName: String?)
        case merchant(category: Store.StoreCategory, username: String)
    }

    public func sendBanubaFilter(_ filter: String, to store: RtmClient.StoreStatus) async -> AgoraRtmSendPeerMessageErrorCode? {
        guard let rtm else { return nil }
        return await rtm.sendBanubaFilter(
            filter, to: store,
            displayName: self.profile?.name ?? "user"
        )
    }

    /// ID logged in the database to link this profile
    @Published var userAccount: String = ""
    @Published var orders: [Order] = []
    var profile: Profile?
    var storeVideoLookup = [String: StoreLiveFeedView]()
}
