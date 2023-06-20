//
//  LoginView.swift
//  LiveCommerce
//
//  Created by Max Cobb on 06/02/2023.
//

import SwiftUI
import AuthenticationServices
import CryptoKit
import FirebaseAuth

struct LoginView: View {
    @State private var selectedSegment = 0
    @State private var showShopCategory = false
    @State private var username = ""
    @State private var password = ""
    @ObservedObject var storeData = StoreData()

    let categories = Store.StoreCategory.allCases
    @State private var selectedCategory: Store.StoreCategory?
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some View {
        VStack {
            Spacer()
            if selectedSegment == 0 {
                SignInWithAppleButton(
                    .signUp
                ) { authRequest in
                    let nonce = randomNonceString()
                    currentNonce = nonce
                    authRequest.requestedScopes = [.fullName]
                    authRequest.nonce = sha256(nonce)
                    print(authRequest)
                } onCompletion: { result in
                    switch result {
                    case let .success(authorization):
                        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                            guard let nonce = currentNonce else {
                              fatalError("Invalid state: A login callback was received, but no login request was sent.")
                            }
                            guard let appleIDToken = appleIDCredential.identityToken else {
                              print("Unable to fetch identity token")
                              return
                            }
                            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                              print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                              return
                            }
                            // Initialize a Firebase credential, including the user's full name.
                            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                                              rawNonce: nonce,
                                                                              fullName: appleIDCredential.fullName)
                            // Sign in with Firebase.
                            Task {
                                guard let result = try? await Auth.auth().signIn(with: credential) else {
                                    // Could not sign in with apple
                                    return
                                }
                                print("result.user.displayName")
                                print(result.user.displayName)
                                self.login(with: result.user.uid, displayName: appleIDCredential.fullName?.givenName)
                            }
                        }
                    case let .failure(signInError):
                        print(signInError)
                    }
                }.frame(height: 44.0).shadow(color: .primary, radius: 2).padding()

            } else if selectedSegment == 1 {
                // Merchant Login
                VStack(alignment: .leading) {
                    AppTextField(placeholder: "Enter your shop name", text: $username, pretext: "Shop Name")
                    AppTextField(placeholder: "Enter your password", text: $password, pretext: "Password", isSecure: true)

                    Text("Shop Category")
                    Picker(selection: $selectedCategory, label: Text("Store Type")) {
                        if selectedCategory == nil {
                            Text("Select Category").tag(nil as String?)
                        }
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                self.selectedCategory = category
                                self.showShopCategory.toggle()
                            }) {
                                Text(category.rawValue)
                            }.tag(category as Store.StoreCategory?)

                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                .padding()

                Button(action: { self.login() }
                ) { Text("Login") }.padding()
            }
            Spacer()
            Picker(selection: $selectedSegment, label: Text("Login Type")) {
                Text("Customer").tag(0)
                Text("Merchant").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selectedSegment, perform: { _ in
                self.password = ""
                self.username = ""
            })
            .padding()

//            .disabled(username.isEmpty || password.isEmpty || selectedCategory == nil)
        }
    }

    // Unhashed nonce.
    @State fileprivate var currentNonce: String?

    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }

    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError(
              "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }

    func login(with username: String? = nil, displayName: String? = nil) {
        let usr = username ?? self.username
        guard !usr.isEmpty else { return }
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let firstWindow = windowScene?.windows.first
        if selectedSegment == 0 {
            self.storeData.loginStatus = .customer(username: usr, displayName: displayName)
            let customerNavigation = CustomerView(storeData: self.storeData)
            firstWindow?.rootViewController = UIHostingController(rootView: customerNavigation)
        } else if let selectedCategory {
            self.storeData.loginStatus = .merchant(category: selectedCategory, username: usr)
            let merchantNavigation = MerchantView(storeData: self.storeData)
            firstWindow?.rootViewController = UIHostingController(rootView: merchantNavigation)
        }
    }
}

struct AppTextField: View {
    var placeholder: String
    @Binding var text: String
    var pretext: String
    var isSecure: Bool = false

    private var textField: AnyView {
        if isSecure {
            return AnyView(SecureField(placeholder, text: $text))
        } else {
            return AnyView(TextField(placeholder, text: $text))
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(pretext)
            textField
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1))
        }
    }
}

struct ShowRow: View {
    var show: Show
    var body: some View {
        HStack {
            Text(show.name)
            Spacer()
            Text(show.date)
        }
    }
}

struct Show {
    var name: String
    var date: String
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
