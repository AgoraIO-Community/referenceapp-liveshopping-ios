//
//  LiveViewRepresentable.swift
//  LiveCommerce
//
//  Created by Max Cobb on 17/02/2023.
//

import SwiftUI
import AgoraUIKit
import AgoraRtcKit
import BanubaFiltersAgoraExtension

struct LiveStreamRepresentView: UIViewRepresentable {
    @Binding var isLive: Bool
    @Binding var showPreview: Bool
    let channelId: String
    @State var banubaEnabled: Bool = false
    @Binding var banubaFilter: (String?, String)?
    @State var filterActive: Bool = false
    func makeUIView(context: Context) -> AgoraVideoViewer {
        var agoraSettings = AgoraSettings()
        agoraSettings.buttonPosition = .left
        agoraSettings.rtmEnabled = false
        agoraSettings.tokenURL = AppKeys.agoraTokenServer
        let strView = AgoraVideoViewer(
            connectionData: AgoraConnectionData(appId: AppKeys.agoraKey),
            style: .grid, agoraSettings: agoraSettings
        )
        strView.setRole(to: AgoraClientRole.broadcaster)
        return strView
    }

    func updateUIView(_ uiView: AgoraVideoViewer, context: Context) {
        if !banubaEnabled {
            self.enableBanuba(for: uiView)
        }
        if self.isLive == (uiView.agConnection.channel == nil) {
            if self.isLive {
                uiView.join(channel: self.channelId, fetchToken: uiView.tokenURL != nil)
            } else {
                uiView.leaveChannel(stopPreview: !self.showPreview)
            }
        } else if !self.isLive {
            if self.showPreview {
                uiView.startPrecallVideo()
            } else {
                uiView.stopPrecallVideo()
            }
        }
        if self.isLive, let banubaFilter = banubaFilter?.0, !filterActive {
            uiView.agkit.setExtensionPropertyWithVendor(
                BNBKeyVendorName,
                extension: BNBKeyExtensionName,
                key: BNBKeyLoadEffect,
                value: banubaFilter
            )
            DispatchQueue.main.async {
                filterActive = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                self.disableFilter(for: uiView)
            }
        }
    }
    func disableFilter(for liveStreamView: AgoraVideoViewer) {
        liveStreamView.agkit.setExtensionPropertyWithVendor(
            BNBKeyVendorName,
            extension: BNBKeyExtensionName,
            key: BNBKeyUnloadEffect,
            value: " "
        )
        filterActive = false
        banubaFilter = nil
    }
    func enableBanuba(for liveStreamView: AgoraVideoViewer) {
        liveStreamView.agkit.enableExtension(
            withVendor: BNBKeyVendorName, extension: BNBKeyExtensionName, enabled: true
        )
        let effectsURL = Bundle.main.bundleURL.appendingPathComponent("effects/", isDirectory: true)
        liveStreamView.agkit.setExtensionPropertyWithVendor(
            BNBKeyVendorName,
            extension: BNBKeyExtensionName,
            key: BNBKeySetEffectsPath,
            value: effectsURL.path)
        liveStreamView.agkit.setExtensionPropertyWithVendor(
            BNBKeyVendorName,
            extension: BNBKeyExtensionName,
            key: BNBKeySetBanubaLicenseToken,
            value: AppKeys.banubaToken
        )
        DispatchQueue.main.async {
            self.banubaEnabled = true
        }
    }
    typealias UIViewType = AgoraVideoViewer
}
