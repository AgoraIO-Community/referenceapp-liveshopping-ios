//
//  ShowtimeRow.swift
//  LiveCommerce
//
//  Created by Max Cobb on 09/03/2023.
//

import SwiftUI

struct ShowtimeRow: View {
    let isMyShow: Bool
    var liveShow: LiveShow
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        let currentWeek = Calendar.current.dateInterval(of: .weekOfYear, for: Date())!
        if Calendar.current.isDateInToday(liveShow.liveShowtime) {
            formatter.dateFormat = "h:mm a"
        } else if currentWeek.contains(liveShow.liveShowtime) {
            formatter.dateFormat = "EEEE\nh:mm a"
        } else {
            formatter.dateFormat = "MMM EEEE\nh:mm a"
        }
        return formatter
    }
    var body: some View {
        HStack {
            if let firebaseImg = liveShow.image, !firebaseImg.isEmpty {
                FirebaseAsyncImage(bucketLocation: .constant(firebaseImg))
                    .frame(width: 50, height: 50)
                    .cornerRadius(25)
            } else {
                Image(systemName: "questionmark.folder")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            Text(liveShow.name)
            Spacer()
            if liveShow.liveShowtime < Date.now, !Calendar.current.isDateInToday(liveShow.liveShowtime) {
                let currentWeek = Calendar.current.dateInterval(of: .weekOfYear, for: Date())!
                Text("\(currentWeek.contains(liveShow.liveShowtime) ? "Last " : "")\(dateFormatter.string(from: liveShow.liveShowtime))")
            } else if Calendar.current.isDateInToday(liveShow.liveShowtime) {
                if liveShow.liveShowtime.timeIntervalSinceNow < 60 * 60 * 2 {
                    Text(self.isMyShow ? "Go Live!" : "Join Now!").foregroundColor(Color.red)
                } else {
                    Text("Today\n\(dateFormatter.string(from: liveShow.liveShowtime))")
                }
            } else {
                Text(dateFormatter.string(from: liveShow.liveShowtime))
            }
        }.multilineTextAlignment(.trailing).padding()
    }
}

struct ShowtimeRow_Previews: PreviewProvider {
    static var previews: some View {
        ShowtimeRow(isMyShow: true, liveShow: LiveShow(image: "images/D1522669-9134-4D0F-A044-322D8F89B5BD", name: "Example Show", id: "1234", liveShowtime: Date(), storeId: "exmaple-store", products: ["one", "two"]))
    }
}
