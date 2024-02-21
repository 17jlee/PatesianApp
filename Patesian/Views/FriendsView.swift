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
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var signedinuser: FetchedResults<SignedInUser>
    @Environment(\.managedObjectContext) var managedObjectContext
    
    func clearAll() async {
        for x in signedinuser {
            managedObjectContext.delete(x)
        }
    }
    
    func addSignedUser(name: String, username: String, friends: [String], profilepic: Data, requestsFrom: [String], subscribedGroups: [String]) async {
        let currentUser = SignedInUser(context: managedObjectContext)
        currentUser.name = name
        currentUser.username = username
        currentUser.friends = friends
        currentUser.profilepic = profilepic
        currentUser.requestsFrom = requestsFrom
        currentUser.subscribedGroups = subscribedGroups
        do {
            try managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var body: some View {
        VStack {
            Text(signedinuser.first?.username ?? "None Given")
            Button("print"){
                for x in signedinuser {
                    print(x.username)
                }
            }
            Button("Insert example") {
                Task {
                    await clearAll()
                    
                    
                    
                }
                
            }
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
