//
//  NewsView.swift
//  Patesian
//
//  Created by Jimin Lee on 27/10/2023.
//

import SwiftUI

struct PlayerView: View {
    let name: String
    
    @State var cached = [[Date: [schoolEvent]]]()
    var body: some View {
        ScrollViewReader{ proxy in
            Button("Jump to #50") {
                withAnimation{
                    
                    proxy.scrollTo(Date.now.stripDate(), anchor: .top)
                }
                
            }
            
            List {
                
                ForEach(cached, id: \.self) { x in
                    Section(x.keys.first!.longdateformat()) {
                        ForEach(x[x.keys.first!]!, id: \.self) { eventObject in
                            HStack {

                                RoundedRectangle(cornerRadius: 50)
                                    .fill(Color.patesRed)
                                    .frame(width: 4, height: 40)
                                VStack {
                                    HStack {
                                        Text("\(String(eventObject.subject))")
                                            .font(Font.headline.weight(.bold))
                                        Spacer()
                                    }

                                    HStack {
                                        if String(eventObject.location) == "" && String(eventObject.teacher) == "" {
                                            Text("")
                                                .padding(.bottom, 3)
                                        }
                                        else if String(eventObject.location) == "" {
                                            Text("\(eventObject.teacher)")
                                                .font(Font.headline.weight(.light))
                                        }
                                        else {
                                            Text("\(String(eventObject.location)) - \(String(eventObject.teacher))")
                                                .font(Font.headline.weight(.light))
                                        }
                                        
                                        Spacer()
                                    }
                                    
                                }

                                Spacer()
                                VStack {
                                    HStack {
                                        Spacer()
                                        Text("\(period(start: eventObject.start, end:eventObject.end))")
                                    }
                                    HStack {
                                        Spacer()
                                        Text("\(eventObject.start.timeformat()) - \(eventObject.end.timeformat())")
                                    }
                                    

                                }
                            }

                        }
                    }
                    
                    .id(x.keys.first!)
                }
            }
            .listStyle(.plain)
                .navigationTitle("Timetable")
                .refreshable {
                    
                    }
                
                
        }.task {
            do {
                try await cached = getTimetable(username: name)
            }
            catch {
                print(error)
            }
            
        }
    }
}


struct FriendsView: View {
    @State var allUsers = [templateUser]()
    @StateObject var mainUser = UserInfo()
    @EnvironmentObject var editMain: UserInfo
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var signedinuser: FetchedResults<SignedInUser>
    @Environment(\.managedObjectContext) var managedObjectContext
    
    func clearAll() async {
        for x in signedinuser {
            managedObjectContext.delete(x)
        }
    }
    
    func performUsersCall() async throws -> [templateUser] {
        let url = URL(string: "https://api.inertiablogs.com/users")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let userWrapper = try decoder.decode(userWrapper.self, from: data)
        return userWrapper.users
    }
    
    func getAllUsers() async -> [templateUser] {
        var allUsers = [templateUser]()
        let url = URL(string: "https://api.inertiablogs.com/users")!
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let userWrapper = try decoder.decode(userWrapper.self, from: data)
            for x in userWrapper.users {
                allUsers.append(x)
            }
        }
        catch {
            print(error)
        }
        return allUsers
    }
    
    func addSignedUser(name: String, username: String, friends: [String], profilepic: Data, requestsFrom: [String], subscribedGroups: [String]) async {
        let currentUser = SignedInUser(context: managedObjectContext)
        currentUser.name = name
        currentUser.username = username
        currentUser.friends = friends
        currentUser.profilepic = profilepic
        currentUser.requestsFrom = requestsFrom
        currentUser.subscribedGroups = subscribedGroups
        print("to save")
        do {
            print("to save")
            try managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateUser() async -> templateUser? {
        if let mainUser = signedinuser.first {
            if let username = mainUser.username {
                let url = URL(string: "https://api.inertiablogs.com/users/\(patesidGet(username).lowercased())")!
                print(url)
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    let decoder = JSONDecoder()
                    print(String(data: data, encoding: String.Encoding.ascii))
                    let serverResponse = try decoder.decode(userWrapper.self, from: data)
                    if let updatedUser = serverResponse.users.first {
                        return updatedUser
                    }
                }
                catch {
                    print(error)
                }
                
                
            }
            
        }
        return nil
    }
    
    var body: some View {
        if let currentUser = signedinuser.first {

            List {
                if !(currentUser.requestsFrom.isEmpty) {
                Section(header: Text("Requests")) {
                    ForEach(currentUser.requestsFrom, id:\.self){ request in
                        HStack {
                            Text(request)
                            Spacer()
                            Button("Accept"){
                                Task {
                                    var oldUser = currentUser.username!
                                    var newRequests = currentUser.requestsFrom
                                    if let index = newRequests.firstIndex(of: request) {
                                        newRequests.remove(at: index)
                                    }
                                    var newFriends = currentUser.friends
                                    newFriends.append(request)
                                    await clearAll()
                                    await addSignedUser(name: currentUser.name!, username: currentUser.username!, friends: newFriends, profilepic: currentUser.profilepic!, requestsFrom: newRequests, subscribedGroups: currentUser.subscribedGroups)
                                    try await updateMetadata(username: oldUser, sample: updatedUser(subscribedGroups: currentUser.subscribedGroups, friends: newFriends, requestsFrom: newRequests))
                                    try await updateMetadata(username: request, sample: updatedUser(subscribedGroups: currentUser.subscribedGroups, friends: newFriends, requestsFrom: newRequests))
                                    try await acceptRequest(request, yourUN: oldUser)
                                    
                                    
                                }
                            }.buttonStyle(.borderless)
                            Button("Deny"){
                                Task {
                                    var oldUser = currentUser.username!
                                    var newRequests = currentUser.requestsFrom
                                    if let index = newRequests.firstIndex(of: request) {
                                        newRequests.remove(at: index)
                                    }
                                    var newFriends = currentUser.friends
                                    await clearAll()
                                    await addSignedUser(name: currentUser.name!, username: currentUser.username!, friends: newFriends, profilepic: currentUser.profilepic!, requestsFrom: newRequests, subscribedGroups: currentUser.subscribedGroups)
                                    try await updateMetadata(username: oldUser, sample: updatedUser(subscribedGroups: currentUser.subscribedGroups, friends: newFriends, requestsFrom: newRequests))
                                    try await denyRequest(request, yourUN: oldUser)
                                    
                                }
                            }.buttonStyle(.borderless)
                        }
                        
                    }
                }
            }
                if !currentUser.friends.isEmpty{
                    Section(header: Text("Friends")) {
                        ForEach(currentUser.friends, id:\.self){ friend in
                            NavigationLink(friend, value: friend)
                                .navigationDestination(for: String.self) { color in
                                    PlayerView(name: color)
                                }
                            
                        }.onDelete(perform: { indexSet in
                            for index in indexSet {
                                let deleteUser = currentUser.friends[index]
                                
                                Task {
                                    var username = currentUser.username!
                                    var newUser = currentUser
                                    newUser.friends.remove(at: index)
                                    print(newUser.friends)
                                    await clearAll()
                                    try await removeRemote(deleteUser, yourUN: currentUser.username!)
                                    try await updateMetadata(username: currentUser.username!, sample: updatedUser(subscribedGroups: newUser.subscribedGroups, friends: newUser.friends, requestsFrom: newUser.requestsFrom))
                                    await addSignedUser(name: currentUser.name!, username: currentUser.username!, friends: newUser.friends, profilepic: newUser.profilepic!, requestsFrom: newUser.requestsFrom, subscribedGroups: newUser.subscribedGroups)
                                    
                                    
                                }
                            }
                            
                        })
                        
                    }
                }
                
                if !allUsers.isEmpty {
                    Section(header: Text("All Registered Users")) {
                        ForEach(allUsers, id:\.self) { user in
                            if !currentUser.requestsFrom.contains(user.username) && !(user.username == currentUser.username) && !(currentUser.friends.contains(user.username)){
                                Button("bruh"){
                                    print(user.username == currentUser.username)
                                    print(currentUser.requestsFrom.contains(user.username))
                                }
                                HStack {
                                    Text("\(user.name) (\(user.username))")
                                    Spacer()
                                    Button("Request") {
                                        Task {
                                            try await sendRequest(user.username, yourUN: currentUser.username!)
                                        }
                                    }.buttonStyle(.borderless)
                                }
                            }
                            
                        }
                    }
                }
                
            }.toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        Task {
                            for x in signedinuser {
                                print(x.friends)
                            }
                            //print(signedinuser.first.friends)

                            
                        }
                    } label: {
                        Image(systemName: "person.crop.circle")
                    }
                }

            }
            .task {
                if let oldUser = signedinuser.first {
                    let newUser = await updateUser()
                    if let successfulUser = newUser {
                        await clearAll()
                        await addSignedUser(name: oldUser.name!, username: oldUser.username!, friends: successfulUser.friends, profilepic: oldUser.profilepic!, requestsFrom: successfulUser.requestsFrom, subscribedGroups: oldUser.subscribedGroups)
                    }
                    
                }
                
                await allUsers = getAllUsers()
                
            }
        }
            
        
        
    }
}

#Preview {
    FriendsView()
}
