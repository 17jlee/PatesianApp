//
//  UserSettings.swift
//  Patesian
//
//  Created by Jimin Lee on 21/02/2024.
//

import Foundation
import SwiftUI

struct loggedinapi: Codable {
    var displayName: String
    var givenName: String
    var surname: String
    var mail: String
}

struct uploadTimetable: Codable {
    let user: String
    let data: [schoolEvent]
}

struct UserSettings: View {
    @EnvironmentObject var settings: loginSettings
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var signedinuser: FetchedResults<SignedInUser>
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var uiimage = UIImage()
    @State var downloaded = Data()
    
    
    
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
        print("to save")
        do {
            print("to save")
            try managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func uploadUserRequest(_ user: User) -> URLRequest? {
        guard let imageData = user.profilepic!.pngData() else {
            // Handle error if unable to convert image to data
            print("unable to convert to png")
            return nil
        }
        
        guard let url = URL(string: "https://api.inertiablogs.com/users") else {
            // Handle error if the URL is invalid
            print("invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        let clrf = "\r\n"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)")
        body.append(clrf)
        body.append("Content-Disposition: form-data; name=\"pfpimage\"; filename=\"\(user.username).png\"")
        body.append(clrf)
        body.append("Content-Type: image/png")
        body.append(clrf)
        body.append(clrf)
        body.append(imageData)
        body.append(clrf)
        body.append("--\(boundary)")
        body.append(clrf)
        body.append("Content-Disposition: form-data; name=\"username\"")
        body.append(clrf)
        body.append(clrf)
        body.append("\(user.username)")
        body.append(clrf)
        body.append("--\(boundary)")
        body.append(clrf)
        body.append("Content-Disposition: form-data; name=\"name\"")
        body.append(clrf)
        body.append(clrf)
        body.append("\(user.name)")
        body.append(clrf)
        body.append("--\(boundary)--")
        body.append(clrf)
        
        request.httpBody = body
        
        return request
        
    }
    
    func uploadUser(user: String, group: String, content: String, image: UIImage) -> URLRequest? {
        guard let imageData = image.pngData() else {
            // Handle error if unable to convert image to data
            print("unable to convert to png")
            return nil
        }
        guard let url = URL(string: "https://api.inertiablogs.com/posts") else {
            // Handle error if the URL is invalid
            print("invalid URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        let clrf = "\r\n"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)")
        body.append(clrf)
        body.append("Content-Disposition: form-data; name=\"postimage\"; filename=\"\(user)-\(group).png\"")
        body.append(clrf)
        body.append("Content-Type: image/png")
        body.append(clrf)
        body.append(clrf)
        body.append(imageData)
        body.append(clrf)
        body.append("--\(boundary)")
        body.append(clrf)
        body.append("Content-Disposition: form-data; name=\"user\"")
        body.append(clrf)
        body.append(clrf)
        body.append("\(user)")
        body.append(clrf)
        body.append("--\(boundary)")
        body.append(clrf)
        body.append("Content-Disposition: form-data; name=\"group\"")
        body.append(clrf)
        body.append(clrf)
        body.append("\(group)")
        body.append(clrf)
        body.append("--\(boundary)")
        body.append(clrf)
        body.append("Content-Disposition: form-data; name=\"content\"")
        body.append(clrf)
        body.append(clrf)
        body.append("\(content)")
        body.append(clrf)
        body.append("--\(boundary)--")
        body.append(clrf)
        
        request.httpBody = body
        
        return request
    }
    
    func returnUser() async  {
        var rawinfo = Data()
        var rawpfpinfo = Data()
        var pfp = UIImage()
        var loggedininfo: loggedinapi? = nil
        var serverResponse: userWrapper? = nil
        var uploadUser: User? = nil
        
        Task {
            try await rawinfo = login(using: settings, endpoint: "https://graph.microsoft.com/v1.0/me?$select=displayName,givenName,surname,mail")
            try await rawpfpinfo = login(using: settings, endpoint: "https://graph.microsoft.com/v1.0/me/photo/$value")
            print(rawpfpinfo)
            if let image = UIImage(data: rawpfpinfo) {
                pfp = image
                print(image)
            }
            let decoder = JSONDecoder()
            loggedininfo = try decoder.decode(loggedinapi.self, from: rawinfo)
            print(loggedininfo)
            if let mail = loggedininfo?.mail {
                print("worked?")
                print(mail)
                let url = URL(string: "https://api.inertiablogs.com/users/\(patesidGet(mail).lowercased())")!
                //let url = URL(string: "https://api.inertiablogs.com/users/\("18jlee")")!
                print(url)
                let (data, _) = try await URLSession.shared.data(from: url)
                let decoder = JSONDecoder()
                do {
                    serverResponse = try decoder.decode(userWrapper.self, from: data)
                }
                catch {
                    print(error)
                    print("empty") //upload the profile
                    uploadUser = User(username: patesidGet(loggedininfo!.mail).lowercased(), name: loggedininfo!.displayName, subscribedGroups: [], profilepic: pfp, requestsFrom: [], friends: [])
                    guard let request = uploadUserRequest(uploadUser!) else {
                        return
                    }
                    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                        // Handle the server response here
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                            return
                        }

                        // Process the response data
                        if let data = data {
                            let responseString = String(data: data, encoding: .utf8)
                            print("Response: \(responseString ?? "")")
                        }
                    }

                    // Start the URLSession task
                    task.resume()
                    await clearAll()
                    
                    await addSignedUser(name: loggedininfo!.givenName, username: patesidGet(loggedininfo!.mail).lowercased(), friends: [], profilepic: rawpfpinfo, requestsFrom: [], subscribedGroups: [])
                    return 
                    
                    
                }
                print(data)
                
                print("bruh \(serverResponse)")
            }
            print("to save here")
            print(serverResponse)
            if let confirmed = serverResponse {
                print("it works maybe\(confirmed.users)")
                if confirmed.users.isEmpty {
                    print("empty") //upload the profile
                    uploadUser = User(username: patesidGet(loggedininfo!.mail).lowercased(), name: loggedininfo!.displayName, subscribedGroups: [], profilepic: pfp, requestsFrom: [], friends: [])
                    guard let request = uploadUserRequest(uploadUser!) else {
                        return
                    }
                    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                        // Handle the server response here
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                            return
                        }

                        // Process the response data
                        if let data = data {
                            let responseString = String(data: data, encoding: .utf8)
                            print("Response: \(responseString ?? "")")
                        }
                    }

                    // Start the URLSession task
                    task.resume()
                    await clearAll()
                    
                    await addSignedUser(name: loggedininfo!.givenName, username: patesidGet(loggedininfo!.mail).lowercased(), friends: [], profilepic: rawpfpinfo, requestsFrom: [], subscribedGroups: [])
                }
                else {
                    await clearAll()
                    await addSignedUser(name: loggedininfo!.givenName, username: patesidGet(loggedininfo!.mail).lowercased(), friends: confirmed.users.first!.friends, profilepic: rawpfpinfo, requestsFrom: confirmed.users.first!.requestsFrom, subscribedGroups: confirmed.users.first!.subscribedGroups)
                }
                
            }
            

            
        }
    }
    
    var body: some View {
        VStack {
            if let profile = signedinuser.first {
                Text("Currently signed in as \(profile.name!) under \(profile.username!)")
                Image(uiImage: UIImage(data: profile.profilepic!)!)
                Button("upload") {
                    Task {
                        var rawResponse = [schoolEvent]()
                        try await rawResponse = uploadjsonParser(json: login(using: settings, endpoint: URLString()))
                        await uploadTimetable(rawResponse, username: profile.username!)
                        
                    }
                }
                
            }
            
            
            
            Button("read through") {
                for x in signedinuser {
                    print(x.username)
                }
            }
            
            Button("try") {
                DispatchQueue.main.async {
                    Task {
                        await returnUser()
                    }
                }
            }
            Image(uiImage: uiimage)
            Button("logout"){
                Task{
                    await clearAll()
                }
            }
            Text("hello")
        }
        
    }
}
