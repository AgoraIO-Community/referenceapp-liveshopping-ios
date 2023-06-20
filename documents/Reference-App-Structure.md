# Reference App Structure: Live Stream Commerce App

This guide walks you through a live shopping reference app, that utilises Agora's Video and Real-time Messaging SDKs, as well as Firebase and several other open source packages.

## Overview

The key features found in this repository are:
- Customer login with Sign In with Apple
- Merchant live stream sessions
- Customers can see all currently live merchants
- Customers can purchase with Apple Pay
- Banuba Face Filters

## Setup

There are a few pieces that need to be in place to set up this project, as it uses a backend service, as well as features from Apple that need to be set-up within your Apple Developer portal.

Firstly, to open the project, you'll need to run `pod install` while in the project root, along side a file named `Podfile`, then open the `LiveCommerce.xcworkspace` file.

### Agora Keys

Inside the AppKeys.swift file there are a few placeholders for various keys and tokens provided by Agora, Firebase, or Banuba.

For the first two agora properties, you will need to fetch a project key for the `agoraKey` property. Head to the [Agora Console](https://console.agora.io) to fetch one from an active project of yours, or create a new project via the console. For the `agoraTokenServer` property, that depends on your project type in the console. If you have an insecure project then you do not need a token, and you can simply assing this to `nil`. If you have a secured application, you'll need to launch a token server, but don't worry, this is incredibly simple with multiple options of one-click deployable token servers:

https://github.com/AgoraIO-Community/agora-token-service

Once launched, add your token server URL in the `agoraTokenServer` property. The other properties will be covered below.

### Firebase

You will need to set-up a firebase account for this application, depending on the app ID given. Head over to firebase's documentation to see how to do this, I couldn't recommend their docs enough.

https://firebase.google.com/docs/ios/setup

The components from Firebase needed are real-time database (customer accounts, store products, orders), storage (images), and Sign In with Apple.

> Add the URL for your firebase instance to `databaseURL`.

When opening the project you may notice a missing GoogleService-Info file. Just add your file provided by Firebase and you'll be good to go.

### Sign In with Apple

Setting up Sign In with Apple is actually quite simple, especially with Firebase's integration. Check out this guide here, to set it up with this application.

https://firebase.google.com/docs/auth/ios/apple

In those docs it also covers configuring Sign In with Apple on the apple developer dashboard.

### Apple Pay

Setting up Apple Pay has also never been easier. This guide from Apple shows all the steps necessary, and so long as you have an active developer account with Apple it won't take long at all.

https://developer.apple.com/documentation/passkit/apple_pay/setting_up_apple_pay

### Banuba

Banuba is a fantastic partner of Agora, providing many face filters that integrate directly into our SDK. To set this up, you'll need to go to the Agora Extensions homepage, and fetch a token from there, and add it to the `banubaToken` property.

## Folder Structure
At a high level, the structure for a this live commerce iOS application consists of the following directories:

```
LiveCommerce/LiveCommerce
├── CustomerViews
├── MerchantViews
├── SharedViews
│   ├── OrderViews
│   └── ProductAndShows
├── AgoraPieces
├── DataConnections
├── Assets.xcassets
└── effects
```

### CustomerViews

The CustomerViews folder contains all the views related to the customer experience in the LiveCommerce application. This includes the user interface for browsing products, creating an account, and making purchases.

### MerchantViews

The MerchantViews folder contains all the views related to the merchant experience in the LiveCommerce application. This includes the user interface for managing products, processing orders, and tracking inventory.

### SharedViews

The SharedViews folder contains views that are shared between both the customer and merchant experiences. This includes views related to orders and products, the login view, and settings.

### SharedViews/OrderViews

The OrderViews folder within SharedViews contains views related to the ordering process, such as the view for showing a list of orders, and the individual cells in that list.

### SharedViews/ProductAndShows

The ProductAndShows folder within SharedViews contains views related to browsing and viewing products, such as the product list page or the product detail page.

### AgoraPieces

The AgoraPieces folder contains all the code related to the integration of Agora's live streaming technology into the LiveCommerce application. This includes the video connections, signalling, and related functionality.

### DataConnections

The DataConnections folder contains all the code related to the data connections used in the LiveCommerce application. This includes connecting to a database to store and retrieve product and order information.

### effects

The effects folder contains the Banuba 3d face filter templates.

## User Flow Diagram

![user flow](../media/live_commerce_shopping_app.png)

In this diagram, you can see that right from the start there are two main scenarios, a customer and a merchant.

The customer has the option to see live stores, their own orders, and all available stores. They also have the option to buy products from stores.

Meanwhile, merchants can see orders made on their store, view their storefront for actions such as updating stock, and can live broadcast to all available customers.

## App Screens

| Customer Login | Merchant Login | No Stores Live | Stores Live |
|:-:|:-:|:-:|:-:|
| ![Customer Login Screen](../media/ss_customer_login.png) | ![Merchant Login Screen](../media/ss_merchant_login.png) | ![No Stores Live Screen](../media/ss_customer_live_empty.png) | ![Stores Live Screen](../media/ss_customer_live_empty.png) |

| All Stores | Storefront | Customer Orders Tab | Merchant Orders Tab |
|:-:|:-:|:-:|:-:|
| ![Stores List View](../media/ss_customer_stores.png) | ![Stores List View](../media/ss_merchant_storefront.png) | ![Customer Login Screen](../media/ss_customer_orders.png) | ![Merchant Login Screen](../media/ss_merchant_orders.png) |

| Go Live View | Choose Product | Buy Product |
|:-:|:-:|:-:|
| ![](../media/golive_merchant.gif) | ![](../media/signaling_merchant_chooseproduct.gif) | ![](../media/applepay_customer_buyproduct.gif) |

| Choose Filter | Banuba Filter |
|:-:|:-:|
| ![](../media/banuba_choose_filter.gif) | ![](../media/banuba_puchase_complete.gif) |

## Agora Overview

The [AgoraPieces](LiveCommerce/LiveCommerce/AgoraPieces) directory contains code related to the Agora SDK integration, which includes real-time audio and video communication functionality for the application. This includes code related to setting up Agora clients and handling various events relating to Agora functionality.

These are the files that can be found in the AgoraPieces directory:

```
AgoraPieces
├── AgoraView.swift
├── BanubaOptionsView.swift
├── StoreLiveFeedView.swift
├── LiveViewRepresentable.swift
└── RtmClient.swift
```

- [AgoraView.swift](LiveCommerce/AgoraPieces/AgoraView.swift): Defines the AgoraView, which is a `UIViewRepresentable`, used to render the Agora Video SDK video streams in SwiftUI. Used in the customer scenario.
- [BanubaOptionsView.swift](LiveCommerce/AgoraPieces/BanubaOptionsView.swift): Defines the BanubaOptionsView, which is a `View` subclass that contains UI elements for configuring the Banuba Face AR SDK. This view appears inside of [StoreLiveFeedView.swift](LiveCommerce/AgoraPieces/StoreLiveFeedView.swift).  Used in the customer scenario.
- [StoreLiveFeedView.swift](LiveCommerce/AgoraPieces/StoreLiveFeedView.swift): Defines the StoreLiveFeedView, which is a SwiftUI `View`. This appears on the customer scenario for each store that is currently live. It contains an AgoraView, BanubaOptionsView, and LiveFeedBuyProductView.
- [LiveViewRepresentable.swift](LiveCommerce/AgoraPieces/LiveViewRepresentable.swift): Defines the LiveViewRepresentable, which is used to show the AgoraVideoViewer from Agora Video UI Kit. LiveViewRepresentable is only used by the merchant when they are going live, as it also has controls such as enabling/disabling the camera and microphone etc.
- [RtmClient.swift](LiveCommerce/AgoraPieces/RtmClient.swift): Defines the RtmClient, which is a wrapper around the Agora Signalling SDK, that provides contains the logic for connecting and disconnecting to RTM channels, fetching tokens, as well as decoding received messages and performing actions based on them, such as displaying a banuba filter or updating a store's live status.

## Agora Features

The following key features from Agora are used within this Application:

- Live Video Streaming
- Signaling (Real-time Messaging)
- Banuba Face Filters

The Agora Features in this app are naturally focused around the live broadcasting features. A merchant can start a channel and go live, while a customer can see who is live and view their streams.

The back-end only keeps track of orders, stock, and user profiles, so to know who is online at any given time, Agora's Signaling (or Real-time Messaging) SDK is also used. This enables us to have messages sent directly between devices, without having to go through our own back-end (in this case, firebase).

If you wanted to instead send that to a server and have someone query it occasionally to see who's online, there's nothing stopping that. But for the Real-time aspect, Signaling does a pretty good job.

### Live Video Streaming

There are two sides to live streaming, that is the broadcaster (merchant in this case), and audience (customer).

The broadcaster's going live view can be found in GoLiveView.swift. This view makes use of Agora's Video UIKit, which offers default buttons for toggling camera and microphone behaviours. A small button is presented at the top for them to switch from a preview state, to live.

<p align="center">
    <img src="../media/golive_merchant.gif" style="max-width:256px">
</p>

The audience view for customers is OnlineStoresView.swift. This view is a collection of all the stores currently online. The user can swipe through the stores, and interact with the nested views (StoreLiveFeedView.swift), by navigating to their storefront, or purchasing the product they are currently selling.

### Signaling

In the same GoLiveView.swift that the merchant sees, they can also select the product they are currently selling. Doing so, sends a message over Agora's Signaling SDK to let customers know the product ID of that item, to also display on their audience view. These messages are sent to the channel whenever the product updates, and directly to a specific customer whenever they join the live stream session.

<p align="center">
    <img src="../media/signaling_merchant_chooseproduct.gif" style="max-width:256px">
</p>

After a customer purchases a product through Apple Pay, a message is sent to the merchant letting them know who has purchased one of their products, and a small confetti animation will appear.

All the signalling methods can be found inside [RtmClient.swift](LiveCommerce/AgoraPieces/RtmClient.swift).

### Banuba Face Filters

After purchasing a product, the customer is also presented with a choice of a few face filters to apply to the host. These face filters are provided by our extensions partner, Banuba.

<p align="center">
    <img src="../media/banuba_choose_filter.gif" style="max-width:256px">
</p>

Once selecting an extension, a message is sent over signaling directly to the merchant, notifying them of face filter that has been selected.
The face filter will automatically apply to the merchant's camera feed, visible to all customers watching the live stream. After 10 seconds, the feed will return to normal.

<p align="center">
    <img src="../media/banuba_puchase_complete.gif" style="max-width:256px">
</p>

## Conclusion

Try out this repo, feel free to adapt it with your own back-end systems using Agora's Real-time tech!

If you have any issues or questions, feel free to open an issue here. If there is a bug we may not necessarily fix it, as this code is open source and should be used as a reference to get you started with your Real-time shopping applications.
