//
//  RtmClient.swift
//  LiveCommerce
//
//  Created by Max Cobb on 18/04/2023.
//

import Foundation
import AgoraRtmKit

protocol RtmClientDelegate: AnyObject {
    var storeOnlineData: [String: RtmClient.StoreStatus] { get set }
    var storeVideoLookup: [String: StoreLiveFeedView] { get set }
    var onlineStoresList: [String] { get set }
    var myStoreStatus: RtmClient.StoreStatus? { get }
    func handleBanubaFilter(_ filter: RtmClient.BanubaFilter, from user: String) async
}

class RtmClient: NSObject, ObservableObject, AgoraRtmDelegate, AgoraRtmChannelDelegate {
    weak var delegate: RtmClientDelegate?
    static var lobbyChannel: String = "live-commerce-lobby"
    var rtm: AgoraRtmKit!
    var username: String
    var loggedIn: Bool = false
    enum ChannelKeys {
        case lobby
        case video
    }
    internal var channels: [ChannelKeys: (channel: AgoraRtmChannel, joined: Bool)] = [:]
    init(delegate: RtmClientDelegate, username: String) {
        self.delegate = delegate
        self.username = username
        super.init()
        self.rtm = AgoraRtmKit(appId: AppKeys.agoraKey, delegate: self)
        if self.rtm == nil {
            print("Could not initialise RTM")
            return
        }
        _Concurrency.Task {
            do {
                try await self.loginJoinLobby(with: username)
            } catch let loginErr as LoginErr {
                print(loginErr)
            }
        }
    }

    enum LoginErr: Error {
        case loginErr(AgoraRtmLoginErrorCode)
        case channelParamErr
        case joinChannelErr(AgoraRtmJoinChannelErrorCode)
    }

    func loginJoinLobby(with username: String) async throws {
        // 🪵 Log-in to RTM
        let loginErr = await self.rtm.login(
            byToken: nil, user: username
        )

        if loginErr != .ok, loginErr != .alreadyLogin {
            throw LoginErr.loginErr(loginErr)
        }
        self.loggedIn = true
        // 🪄 Create RTM Channel
        guard let channel = self.rtm.createChannel(
            withId: RtmClient.lobbyChannel, delegate: self
        ) else { throw LoginErr.channelParamErr }

        self.channels[.lobby] = (channel, false)
        // ⛓️ Join RTM Channel
        let joinErr = await channel.join()
        if joinErr != .channelErrorOk {
            throw LoginErr.joinChannelErr(joinErr)
        }
        // 🎉 Logged-in and joined a channel
        self.channels[.lobby]?.joined = true
    }

    struct StoreStatus: Codable {
        var isLive: Bool
        var isOnline: Bool
        var channelName: String {
            self.storeId
        }
        var storeId: String
        var memberId: String
        var showingProduct: String?
        var lastUpdate: Date?
    }

    func sendStoreStatusUpdate(status: StoreStatus?) async {
        guard let status else { return }
        guard let agoraMsg = try? self.rtmFromCodable(msg: status) else { return }
        if self.channels[.lobby]?.joined == true {
            let sendResp = await self.channels[.lobby]?.channel.send(agoraMsg)
            if sendResp    != .errorOk {
                print("could not send message: \(sendResp.debugDescription)")
            }
        }
    }

    struct BanubaFilter: Codable {
        var filterName: String
        var productId: String
        var buyerDisplay: String?
    }

    func sendBanubaFilter(_ filter: String, to store: StoreStatus, displayName: String) async -> AgoraRtmSendPeerMessageErrorCode {
        guard let productId = store.showingProduct,
              let msg = try? self.rtmFromCodable(
                msg: BanubaFilter(filterName: filter, productId: productId, buyerDisplay: displayName)
        ) else {
            return .incompatibleMessage
        }
        return await self.rtm.send(msg, toPeer: store.memberId)
    }

    func rtmFromCodable(msg: Codable) throws -> AgoraRtmMessage {
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(msg)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        return AgoraRtmMessage(text: jsonString)
    }

    func decodeMessage(_ message: AgoraRtmMessage, from memberId: String, in channel: AgoraRtmChannel?) {
        let jsonData = message.text.data(using: .utf8)!
        let decoder = JSONDecoder()
        if let storeStatus = try? decoder.decode(StoreStatus.self, from: jsonData) {
            self.delegate?.storeOnlineData[storeStatus.storeId] = storeStatus
            if storeStatus.isLive != self.delegate?.onlineStoresList.contains(where: { $0 == storeStatus.storeId }) {
                if storeStatus.isLive {
                    self.delegate?.onlineStoresList.append(storeStatus.storeId)
                } else {
                    self.delegate?.onlineStoresList.removeAll { $0 == storeStatus.storeId }
                }
            }
            self.delegate?.storeVideoLookup[storeStatus.storeId]?.selectedProduct = storeStatus.showingProduct
            self.delegate?.storeVideoLookup[storeStatus.storeId]?.lastUpdate = storeStatus.lastUpdate
        } else if let banubaFilter = try? decoder.decode(BanubaFilter.self, from: jsonData) {
            Task {
                await self.delegate?.handleBanubaFilter(banubaFilter, from: memberId)
            }
        } else {
            print("Could not decode message! \(message.text)")
        }
    }

    func channel(_ channel: AgoraRtmChannel, memberLeft member: AgoraRtmMember) {
        if member.channelId == RtmClient.lobbyChannel {
            if let storeKey = self.delegate?.storeOnlineData.first(where: { keyval in
                keyval.value.memberId == member.userId
            })?.key {
                self.delegate?.storeOnlineData.removeValue(forKey: storeKey)
            }
        }
    }

    func channel(_ channel: AgoraRtmChannel, messageReceived message: AgoraRtmMessage, from member: AgoraRtmMember) {
        self.decodeMessage(message, from: member.userId, in: channel)
    }

    func rtmKit(_ kit: AgoraRtmKit, messageReceived message: AgoraRtmMessage, fromPeer peerId: String) {
        self.decodeMessage(message, from: peerId, in: nil)
    }

    func channel(_ channel: AgoraRtmChannel, memberJoined member: AgoraRtmMember) {
        guard let status = self.delegate?.myStoreStatus,
              let rtmMsg = try? self.rtmFromCodable(msg: status) else {
            return
        }
        self.rtm.send(rtmMsg, toPeer: member.userId)
    }

    func fetchNewToken() {

    }
    func checkConnectionSpeed() {

    }
}
