//
//  File.swift
//  
//
//  Created by Jimin Lee on 17/02/2024.
//

import Foundation
import SwiftUI

func performGroupsCall() async throws -> [templateGroups] {
    let url = URL(string: "https://api.inertiablogs.com/groups")!
    let (data, _) = try await URLSession.shared.data(from: url)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(dateFormatter)
    let groupWrapper = try decoder.decode(groupWrapper.self, from: data)
    return groupWrapper.groups
}

func groupsGet() async throws -> [Groups]{
    var posts = [Groups]()
    let records = try? await performGroupsCall()
    if let good = records {
        for x in good {
            if let urlnow = x.image {
                let urll = URL(string: "https://api.inertiablogs.com/posts/download/"+urlnow)
                let image = try? await downloadImageData(from: urll!)
                if let downloaded = image {
                    posts.append(Groups(name: x.name, members: x.members, room: x.room, instagram: x.instagram, description: x.description, image:downloaded))
                }
                
            }
            else {
                posts.append(Groups(name: x.name, members: x.members, room: x.room, instagram: x.instagram, description: x.description, image:nil))
            }
        }
    }
    else {
        print("empty")
    }
    
    return posts
}


func sortGroups(_ groups: [Groups]) -> [String: Groups] {
    var result = [String : Groups]()
    for x in groups {
        result[x.name] = x
    }
    return result
}



