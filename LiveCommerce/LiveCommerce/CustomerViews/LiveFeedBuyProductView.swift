//
//  LiveFeedBuyProductview.swift
//  LiveCommerce
//
//  Created by Max Cobb on 15/03/2023.
//

import SwiftUI
import PassKit

struct LiveFeedBuyProductView: View {
    @ObservedObject var paymentDelegate = PaymentManager()
    @State var productSelected = false
    @Binding var productString: String?
    @Binding var lastUpdate: Date?
    @State var productImgLoc: String?
    public var purchasedProduct: ((Product) -> Void)?
    @State var product: Product?
    @State var _prevLastUpdate: Date?
    @State var productLookup: [String: Product] = [:]
    var body: some View {
        VStack {
            if self.paymentDelegate.paymentStatus == .authorized {
                // show banuba thing
                EmptyView()
            } else if productString == nil {
                // no proiduct selected
                EmptyView()
            } else if let productString, (product == nil || product?.id != productString) {
                // product selected
                // need to get product details or have old details
                EmptyView()
            } else if let product {
                // got product data, show it.
                HStack {
                    FirebaseAsyncImage(bucketLocation: $productImgLoc)
                        .scaledToFill()
                        .frame(
                            width: 80,
                            height: 80
                        ).cornerRadius(5)
                    HStack {
                        VStack(alignment: .leading) {
                            Text(product.name)
                            Text("$\(product.price, specifier: "%.2f")")
                            if product.stock > 0 {
                                Text("\(product.stock) Left!")
                            } else { Text("Sold out!") }
                        }
                        Spacer()
                        Image(systemName: "chevron.up")
                            .foregroundColor(Color.blue)
                            .rotationEffect(productSelected ? .degrees(-180) : .degrees(0))
                    }.padding().frame(height: 80).background(.tertiary).onTapGesture {
                        withAnimation {
                            self.productSelected.toggle()
                        }
                    }

                }.padding([.bottom])
                // Buy or out of stock buttons
                if self.productSelected {
                    if product.stock > 0 {
                        Button {
                            paymentDelegate.startPayment(product: product)
                        } label: {
                            Text("")
                        }.frame(height: 50).buttonStyle(ApplePayButtonStyle())
                    } else {
                        Button {
                            print("no stock")
                        } label: {
                            HStack {
                                Spacer()
                                Text("Out of Stock").fontWeight(Font.Weight.heavy)
                                Spacer()
                            }.padding(15).background(.black).cornerRadius(4)
                                .disabled(true)
                        }

                    }
                }
            }
        }.padding()
            .onChange(of: productString) { _ in
                self.fetchProduct()
            }.onChange(of: self.paymentDelegate.paymentStatus, perform: { newValue in
                if newValue == .completed {
                    self.paymentDelegate.paymentStatus = .none
                    if let product, let purchasedProduct {
                        purchasedProduct(product)
                    }
                }
            }).onChange(of: lastUpdate) { newValue in
                if let newValue,
                   (self._prevLastUpdate == nil
                    || newValue.compare(self._prevLastUpdate ?? Date()) == .orderedDescending) {
                    DispatchQueue.main.async {
                        self.product = nil
                        self.productLookup.removeAll()
                        self.productImgLoc = nil
                        self.fetchProduct()
                    }
                }
                self._prevLastUpdate = newValue
            }
    }
    func fetchProduct() {
        guard let productId = productString else {
            self.product = nil
            return
        }
        if productId == product?.id {
            return
        }
        if let product = productLookup[productId] {
            DispatchQueue.main.async {
                self.product = product
                self.productImgLoc = product.image
            }
        } else {
            Task {
                guard let product: Product = await FirebaseConnect.shared.getObject(
                    from: "products", id: productId
                ) else { return }
                if product.id == productId {
                    // if the id hasn't changed since the fetch began.
                    self.productLookup[product.id] = product
                    DispatchQueue.main.async {
                        self.product = product
                        self.productImgLoc = product.image
                    }
                }
            }
        }
    }
}

class PaymentManager: NSObject, ObservableObject {
    enum PaymentStatus {
        case none
        case authorized
        case completed
        case cancelled
    }

    @Published var paymentStatus: PaymentStatus = .none

    func startPayment(product: Product) {
        // Trigger the payment flow
        let paymentRequest = PKPaymentRequest()
        paymentRequest.merchantIdentifier = "merchant.uk.rocketar.livecommerce"
        paymentRequest.supportedNetworks = [.visa, .masterCard, .amex]
        paymentRequest.merchantCapabilities = .capability3DS
        paymentRequest.countryCode = "US"
        paymentRequest.currencyCode = "USD"
        paymentRequest.paymentSummaryItems = [PKPaymentSummaryItem(label: product.name, amount: NSDecimalNumber(value: product.price), type: .final)]

        let controller = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        controller.delegate = self
        controller.present()
    }
}
extension PaymentManager: PKPaymentAuthorizationControllerDelegate {
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // Handle the payment authorization
        self.paymentStatus = .authorized

        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }

    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        // Dismiss the payment flow
        controller.dismiss {
            DispatchQueue.main.async {
                if self.paymentStatus == .none {
                    self.paymentStatus = .cancelled
                } else {
                    self.paymentStatus = .completed
                }
            }
        }
    }
}

struct ApplePayButton: UIViewRepresentable {
    func updateUIView(_ uiView: PKPaymentButton, context: Context) {

    }
    func makeUIView(context: Context) -> PKPaymentButton {
        return PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .black)
    }
}
struct ApplePayButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        return ApplePayButton()
    }
}

struct LiveFeedBuyProductView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            LiveFeedBuyProductView(productString: .constant("example-product"), lastUpdate: .constant(nil), product: Product(image: "images/D1522669-9134-4D0F-A044-322D8F89B5BD", name: "Example", price: 10.99, stock: 4, id: "example-product"))
        }
    }
}
