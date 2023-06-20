//
//  GoLiveView.swift
//  LiveCommerce
//
//  Created by Max Cobb on 12/04/2023.
//

import SwiftUI

struct GoLiveView: View {
    @ObservedObject var storeData: StoreData
    @State var isLive = false
    @State var showPreview = false
    @State var confettiTrigger = 0
    var body: some View {
        ZStack {
            LiveStreamRepresentView(
                isLive: $isLive, showPreview: $showPreview,
                channelId: storeData.myStore!.id, banubaFilter: $storeData.banubaFilter
            )
            VStack {
                HStack {
                    Spacer()
                    GoLiveButton(isLive: self.$isLive) { isLive in
                        self.storeData.myStoreStatus?.isLive = isLive
                    }
                }
                Spacer()
                ChooseItemView(store: storeData.myStore!) { chosenProduct in
                    self.storeData.myStoreStatus?.showingProduct = chosenProduct
                }
            }
            if let buyerName = storeData.banubaFilter?.1 {
                GroupBox {
                    Text("New Purchase from \(buyerName)!")
                        .padding()
                }.cornerRadius(7)
            }
        }.onChange(of: storeData.banubaFilter?.1) { newValue in
            if newValue != nil {
                confettiTrigger += 1
            }
        }.onDisappear {
            self.isLive = false
            self.storeData.myStoreStatus?.isLive = false
            self.showPreview = false
        }.onAppear {
            self.isLive = false
            self.storeData.myStoreStatus?.isLive = false
            self.showPreview = true
        }.confettiCannon(
            counter: $confettiTrigger, num: 20, rainHeight: 800,
            openingAngle: .degrees(50), closingAngle: .degrees(130),
            radius: 400, repetitions: 3, repetitionInterval: 0.15
        )
    }
}

struct GoLiveButton: View {
    @State var goingLive = 0
    @Binding var isLive: Bool
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        Button {
            if isLive {
                isLive = false
                isLiveCallback(false)
            } else if goingLive != 0 {
                goingLive = 0
            } else {
                goingLive = 3
            }
        } label: {
            HStack {
                Text(isLive ? "End Show" : (
                    goingLive == 0 ? "Go Live" : "Live in: \(goingLive) second\(goingLive > 1 ? "s" : "")"
                )).onReceive(timer) { _ in
                    if self.isLive || goingLive == 0 { return }
                    goingLive -= 1
                    if goingLive == 0 {
                        self.isLive = true
                        isLiveCallback(true)
                    }
                }
                Image(systemName: "record.circle")
            }.padding(3).overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(isLive ? .red : .black, lineWidth: 1))
        }.tint(
            isLive ? .red : .black
        ).padding().onAppear {
            self.goingLive = 0
        }.onDisappear {
            self.goingLive = 0
        }
    }
    var isLiveCallback: (Bool) -> Void
}
