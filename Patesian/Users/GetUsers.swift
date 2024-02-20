//
//  GetUsers.swift
//  Patesian
//
//  Created by Jimin Lee on 17/02/2024.
//

import Foundation
import SwiftUI

struct userWrapper: Codable {
    let users: [templateUser]
}

struct templateUser: Codable {
    let username: String
    let name: String
    let subscribedGroups: [String]
    let profilepic: String
    let requestsFrom: [String]
    let friends: [String]
}

struct User: Hashable {
    let username: String
    let name: String
    let subscribedGroups: [String]
    let profilepic: UIImage
    let requestsFrom: [String]
    let friends: [String]
}

func performUsersCall() async throws -> [templateUser] {
    let url = URL(string: "https://api.inertiablogs.com/users")!
    let (data, _) = try await URLSession.shared.data(from: url)
    let decoder = JSONDecoder()
    let userWrapper = try decoder.decode(userWrapper.self, from: data)
    //print(error)
    return userWrapper.users
}

func resolveUsersTemplate() async throws -> [User] {
    var Users = [User]()
    let templates = try? await performUsersCall()
    if let retrievedData = templates {
        for x in retrievedData {
                let filename = x.profilepic
                let urll = URL(string: "https://api.inertiablogs.com/users/download/"+filename)
                let image = try? await downloadImageData(from: urll!)
                if let downloaded = image {
                    Users.append(User(username: x.username, name: x.name, subscribedGroups: x.subscribedGroups, profilepic: downloaded, requestsFrom: x.requestsFrom, friends: x.friends))
                }
                
            
        }
    }
    return Users
}
