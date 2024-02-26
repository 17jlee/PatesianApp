//
//  File.swift
//  
//
//  Created by Jimin Lee on 17/02/2024.
//

import Foundation
import SwiftUI

func downloadImageData(from url: URL) async throws -> UIImage {
    let request = URLRequest(url: url)
    let (data, _) = try await URLSession.shared.data(for: request)
    return UIImage(data: data) ?? UIImage()
}

func performAPICall() async throws -> [templatePosts] {
    let url = URL(string: "https://api.inertiablogs.com/posts")!
    let (data, _) = try await URLSession.shared.data(from: url)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(dateFormatter)
    let wrapper = try decoder.decode(Wrapper.self, from: data)
    return wrapper.posts
}

func getTimetable(username: String) async throws -> [[Date: [schoolEvent]]] {
    var intermediary = [Date: [schoolEvent]]()
    let url = URL(string: "https://api.inertiablogs.com/timetables/\(username)")!
    let (data, _) = try await URLSession.shared.data(from: url)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(dateFormatter)
    let wrapper = try decoder.decode(timetableWrapper.self, from: data)
    for x in wrapper.data {
        if let array = intermediary[x.start.stripDate()] {
            intermediary[x.start.stripDate()]?.append(x)
        }
        else {
            intermediary[x.start.stripDate()] = [x]
        }
        
    }
    let result = intermediary.sorted {
        $0.0 < $1.0
    }
    var sorted = [[Date: [schoolEvent]]]()
    for x in result {
        sorted.append([x.key : x.value])
        
    }
    return sorted
}

func resolvePostTemplate() async throws -> [Posts]{
    var posts = [Posts]()
    let templates = try? await performAPICall()
    if let retrievedData = templates {
        for x in retrievedData {
            if let urlnow = x.image {
                let urll = URL(string: "https://api.inertiablogs.com/posts/download/"+urlnow)
                let image = try? await downloadImageData(from: urll!)
                if let downloaded = image {
                    posts.append(Posts(user: x.user, group: x.group, title: nil, content: x.content, image: downloaded, date: x.date))
                }
                
            }
            else {
                posts.append(Posts(user: x.user, group: x.group, title: nil, content: x.content, image: nil, date: x.date))
            }
        }
    }
    else {
        print("empty")
    }
    
    return posts
}

