//
//  User Info.swift
//  Patesian
//
//  Created by Jimin Lee on 19/02/2024.
//

import Foundation
import SwiftUI

class UserInfo: ObservableObject {
    @Published var signedInUser = User(username: String(), name: String(), subscribedGroups: [String](), profilepic: UIImage(), requestsFrom: [String](), friends: [String]())
}
