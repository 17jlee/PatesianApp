//
//  NewsView.swift
//  Patesian
//
//  Created by Jimin Lee on 27/10/2023.
//

import SwiftUI

struct NewsView: View {
    var body: some View {
        VStack {
            List {
                Text("Yaksh Mithani Gets Banned From the Music Room!")
                Text("Elif awarded Miss Pate's 2023")
                Text("Michael fumbles another baddie??")
                Text("Aabha loses another scrunchie???")
                Text("Jimin Fails Physics in Mocks!?!")
            }
            Button("bruh") {
                let huh = schoolEvent(subject: "ass", teacher: "teach", location: "ya", start: Date.now, end: Date.now)
                print(huh)
            }
        }
    }
}

#Preview {
    NewsView()
}
