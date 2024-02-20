//
//  NewsView.swift
//  Patesian
//
//  Created by Jimin Lee on 27/10/2023.
//

import SwiftUI

struct FriendsView: View {
    @State var Users = [User]()
    @StateObject var mainUser = UserInfo()
    @EnvironmentObject var editMain: UserInfo
    
    var body: some View {
        VStack {
            
            List {
                Text(mainUser.signedInUser.name)
                    .environmentObject(mainUser)
                ForEach(Users, id:\.self) { User in
                    Text("\(User.username) \(User.name) ")
                    Image(uiImage: User.profilepic)
                    
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    Task {
                        try await Users = resolveUsersTemplate()
                        print("here")
                        editMain.signedInUser = Users.first!
                        
                    }
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
