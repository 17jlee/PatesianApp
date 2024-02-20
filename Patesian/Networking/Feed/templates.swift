//
//  templates.swift
//  PatesianAPI
//
//  Created by Jimin Lee on 17/02/2024.
//

import Foundation
import SwiftUI

struct Wrapper: Codable {
    let posts: [templatePosts]
}

struct groupWrapper: Codable {
    let groups: [templateGroups]
}

struct templatePosts: Codable, Hashable {
    let user: String
    let group: String
    let title: String?
    let content: String
    let image: String?
    let date: Date
}


struct templateGroups: Codable, Hashable {
    let name: String
    let members: [String]
    let room: String
    let instagram: String?
    let description: String
    let image: String?
}

struct Groups: Hashable {
    let name: String
    let members: [String]
    let room: String
    let instagram: String?
    let description: String
    let image: UIImage?
}



struct Posts: Hashable {
    let user: String
    let group: String
    let title: String?
    let content: String
    let image: UIImage?
    let date: Date
}

struct uploadPosts: Encodable {
    let user: String
    let group: String
    let content: String
    let postimage: Data?
    let date: Date
}

struct completePosts {
    let posts: [templatePosts]
}


