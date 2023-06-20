//
//  AgoraView.swift
//  LiveCommerce
//
//  Created by Max Cobb on 13/03/2023.
//

import SwiftUI
import AgoraRtcKit

protocol JoinCallHandler {
    func remoteUserJoined(engine: AgoraRtcEngineKit, didJoinedOfUid: UInt, elapsed: Int)
}

class ChannelExDelegate: NSObject, AgoraRtcEngineDelegate {
    var callHandler: JoinCallHandler?
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        callHandler?.remoteUserJoined(engine: engine, didJoinedOfUid: uid, elapsed: elapsed)
    }
}

extension AgoraRtcVideoCanvas: ObservableObject {}

struct AgoraView: UIViewRepresentable, JoinCallHandler {
    @StateObject var canvas = AgoraRtcVideoCanvas()
    @State var uid: UInt?
    var localUid: Int
    var channelExDelegate: ChannelExDelegate? = ChannelExDelegate()
    @ObservedObject var storeData: StoreData
    func makeUIView(context: Context) -> UIView {
        let bgView = UIView()
//        let videoView = UIView()
//        bgView.addSubview(videoView)
//        videoView.frame = .init(origin: .zero, size: CGSize(width: 100, height: 100))
        canvas.renderMode = .fit
        canvas.view = bgView
        channelExDelegate?.callHandler = self
        defer {
            self.storeData.rtc.joinChannelEx(
                byToken: nil, connection: AgoraRtcConnection(channelId: channelName, localUid: localUid),
                delegate: self.channelExDelegate, mediaOptions: AgoraRtcChannelMediaOptions(),
                joinSuccess: nil
            )
        }
        return bgView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let uid, canvas.uid != uid {
            print("setting up canvas \(uid)")
            print()
            canvas.uid = uid
            storeData.rtc.setupRemoteVideoEx(canvas, connection: AgoraRtcConnection(channelId: channelName, localUid: localUid))
//            storeData.rtc.muteRemoteVideoStream(uid, mute: false)
//            uiView.subviews.first?.isHidden = false
        } else if uid == nil {
            uiView.subviews.first?.isHidden = true
        }
    }

    func remoteUserJoined(engine: AgoraRtcEngineKit, didJoinedOfUid: UInt, elapsed: Int) {
        print("\(didJoinedOfUid) joined")
        self.uid = didJoinedOfUid
    }

    typealias UIViewType = UIView

    // AgoraRtcEngineKit variables
    var agoraKit: AgoraRtcEngineKit {
        self.storeData.rtc
    }
    let channelName: String

    // View variables
    var remoteUid: UInt?
}

struct AgoraView_Previews: PreviewProvider {
    static var previews: some View {
        AgoraView(localUid: 3333, storeData: StoreData(), channelName: "example")
    }
}
