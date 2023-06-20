//
//  BanubaOptionsView.swift
//  LiveCommerce
//
//  Created by Max Cobb on 17/03/2023.
//

import SwiftUI

struct BanubaOptionsView: View {
    @State var filterNames = [("test_Glasses", "eyeglasses"), ("CubemapEverest", "figure.pool.swim"), ("ActionunitsGrout", "tree.fill"), ("BulldogHarlamov", "pawprint.fill")]
    @State var filterSelected: String?
    var showFilters: [(String, String)] {
        if let filterSelected {
            return filterNames.filter { $0.0 == filterSelected }
        } else { return self.filterNames }
    }
    @Binding var isPresented: Bool
    var storeId: String
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var autoDismiss: Int = 10
    func applyFilter(filterName: String) {
        // Apply the selected filter to the separate view
        // This function should be implemented in the parent view that presents this view
        withAnimation {
            filterSelected = filterName
        }
        self.filterSelectedCallback(filterName)
    }
    var filterSelectedCallback: (String) -> Void

    var body: some View {
        VStack(alignment: .center) {
            if showFilters.count > 1 {
                Text("""
                Thanks for your purchase!
                Apply a filter to the host:
                """)
                .multilineTextAlignment(.center)
                .padding([.bottom], 5)
            }
            HStack {
                ForEach(showFilters, id: \.1) { (filterName, symbolName) in
                    Button(action: {
                        if self.showFilters.count > 1 {
                            applyFilter(filterName: filterName)
                            self.autoDismiss = 3
                        }
                    }, label: {
                        Image(systemName: symbolName)
                            .font(.system(size: 50))
                    })
                }
            }
            if showFilters.count > 1 {
                Button(action: {
                    applyFilter(filterName: "none")
                    withAnimation {
                        self.isPresented = false
                        self.autoDismiss = 0
                    }
                }, label: {
                    Text("Dismiss (\(self.autoDismiss))")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.7))
                        .cornerRadius(10)
                })
            }
        }.padding().background(.tertiary).cornerRadius(10)
        .onDisappear {
            if self.isPresented {
                self.isPresented = false
            }
            self.filterSelected = nil
        }.onChange(of: self.isPresented) { _ in
            if self.isPresented {
                self.autoDismiss = 10
            }
        }.onReceive(timer) { _ in
            guard isPresented, autoDismiss > 0 else { return }
            self.autoDismiss -= 1
            guard self.autoDismiss > 0 else {
                if self.filterSelected == nil {
                    self.applyFilter(filterName: "none")
                }
                withAnimation {
                    self.isPresented = false
                }
                return
            }
        }
    }
}

struct BanubaOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        BanubaOptionsView(isPresented: .constant(true), storeId: "", filterSelectedCallback: { filter in
            print(filter)
        })
    }
}
