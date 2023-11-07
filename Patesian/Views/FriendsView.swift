//
//  NewsView.swift
//  Patesian
//
//  Created by Jimin Lee on 27/10/2023.
//

import SwiftUI

struct FriendsView: View {
    var body: some View {
        VStack {
            List {
                Text("Yaksh Mithani Gets Banned From the Music Room!")
                Text("The Magic Number is 46")
                Text("Michael fumbles another baddie??")
                Text("Aabha loses another scrunchie???")
                Text("Jimin Fails Physics in Mocks!?!")
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    //listView.toggle()
                    //print(settings.sortedData)
                    //cached.append([Date.now : [schoolEvent(subject: "ff", teacher: "gg", location: "hh", start: Date.distantFuture, end: Date.distantPast)]])
                } label: {
                    Image(systemName: "person.crop.circle")
                }
            }

        }
    }
}

#Preview {
    FriendsView()
}
