//
//  Update User.swift
//  Patesian
//
//  Created by Jimin Lee on 24/02/2024.
//

import Foundation

struct updatedUser: Codable {
    let subscribedGroups: [String]
    let friends: [String]
    let requestsFrom: [String]
}


struct RequestTemplate: Codable {
    let requestsFrom: [String]
}

struct RemoveTemplate: Codable {
    let friends: [String]
}

struct AcceptTemplate: Codable {
    let requestsFrom: [String]
    let friends: [String]
}

func updateMetadata(username: String, sample: updatedUser) async throws {
    print(sample.friends)
    print(sample.requestsFrom)
    let url = URL(string: "https://api.inertiablogs.com/users/\(username)")!
    var request = URLRequest(url: url)
    request.httpMethod = "PATCH"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    let data = try JSONEncoder().encode(sample)
    print("request is \(request)")
    let (_, response) = try await URLSession.shared.upload(for: request, from: data)
   print(response)
}


func sendRequest(_ username: String, yourUN: String) async throws {
    var allUsers = [templateUser]()
    let url1 = URL(string: "https://api.inertiablogs.com/users/\(username)")!
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url1)
        let decoder = JSONDecoder()
        let userWrapper = try decoder.decode(userWrapper.self, from: data)
        for x in userWrapper.users {
            allUsers.append(x)
        }
    }
    catch {
        print(error)
    }
    if let target = allUsers.first {
        var newRequests = target.requestsFrom
        newRequests.append(yourUN)
        
        let url = URL(string: "https://api.inertiablogs.com/users/\(username)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try JSONEncoder().encode(RequestTemplate(requestsFrom: newRequests))
        print("request is \(request)")
        let (_, response) = try await URLSession.shared.upload(for: request, from: data)
       print(response)
    }
}

func acceptRequest(_ username: String, yourUN: String) async throws {
    var allUsers = [templateUser]()
    let url1 = URL(string: "https://api.inertiablogs.com/users/\(username)")!
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url1)
        let decoder = JSONDecoder()
        let userWrapper = try decoder.decode(userWrapper.self, from: data)
        for x in userWrapper.users {
            allUsers.append(x)
        }
    }
    catch {
        print(error)
    }
    if let target = allUsers.first {
        var newRequests = target.requestsFrom
        var newFriends = target.friends
        
        if let index = newRequests.firstIndex(of: yourUN) {
            newRequests.remove(at: index)
        }
        
        newFriends.append(yourUN)
        
        let url = URL(string: "https://api.inertiablogs.com/users/\(username)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try JSONEncoder().encode(AcceptTemplate(requestsFrom: newRequests, friends: newFriends))
        print("request is \(request)")
        let (_, response) = try await URLSession.shared.upload(for: request, from: data)
       print(response)
    }
}

func denyRequest(_ username: String, yourUN: String) async throws {
    var allUsers = [templateUser]()
    let url1 = URL(string: "https://api.inertiablogs.com/users/\(username)")!
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url1)
        let decoder = JSONDecoder()
        let userWrapper = try decoder.decode(userWrapper.self, from: data)
        for x in userWrapper.users {
            allUsers.append(x)
        }
    }
    catch {
        print(error)
    }
    if let target = allUsers.first {
        var newRequests = target.requestsFrom
        var newFriends = target.friends
        
        if let index = newRequests.firstIndex(of: yourUN) {
            newRequests.remove(at: index)
        }
        
        let url = URL(string: "https://api.inertiablogs.com/users/\(username)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try JSONEncoder().encode(AcceptTemplate(requestsFrom: newRequests, friends: newFriends))
        print("request is \(request)")
        let (_, response) = try await URLSession.shared.upload(for: request, from: data)
       print(response)
    }
}

func removeRemote(_ username: String, yourUN: String) async throws {
    var allUsers = [templateUser]()
    let url1 = URL(string: "https://api.inertiablogs.com/users/\(username)")!
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url1)
        let decoder = JSONDecoder()
        let userWrapper = try decoder.decode(userWrapper.self, from: data)
        for x in userWrapper.users {
            allUsers.append(x)
        }
    }
    catch {
        print(error)
    }
    if let target = allUsers.first {
        //var newRequests = target.requestsFrom
        var newFriends = target.friends
        
        if let index = newFriends.firstIndex(of: yourUN) {
            newFriends.remove(at: index)
        }
        
        let url = URL(string: "https://api.inertiablogs.com/users/\(username)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try JSONEncoder().encode(RemoveTemplate(friends: newFriends))
        print("request is \(request)")
        let (_, response) = try await URLSession.shared.upload(for: request, from: data)
       print(response)
    }
}
