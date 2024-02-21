//
//  SignedInUser+CoreDataProperties.swift
//  Patesian
//
//  Created by Jimin Lee on 20/02/2024.
//
//

import Foundation
import CoreData


extension SignedInUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SignedInUser> {
        return NSFetchRequest<SignedInUser>(entityName: "SignedInUser")
    }

    @NSManaged public var username: String?
    @NSManaged public var name: String?
    @NSManaged public var subscribedGroups: [String]
    @NSManaged public var profilepic: Data?
    @NSManaged public var requestsFrom: [String]
    @NSManaged public var friends: [String]

}

extension SignedInUser : Identifiable {

}
