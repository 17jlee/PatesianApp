//
//  CachedPosts+CoreDataProperties.swift
//  Patesian
//
//  Created by Jimin Lee on 21/02/2024.
//
//

import Foundation
import CoreData


extension CachedPosts {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedPosts> {
        return NSFetchRequest<CachedPosts>(entityName: "CachedPosts")
    }

    @NSManaged public var content: String?
    @NSManaged public var date: Date?
    @NSManaged public var group: String?
    @NSManaged public var postimage: Data?
    @NSManaged public var user: String?

}

extension CachedPosts : Identifiable {

}
