//
//  Day+CoreDataProperties.swift
//  dataModel2
//
//  Created by Jimin Lee on 04/11/2023.
//
//

import Foundation
import CoreData


extension Day {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Day> {
        return NSFetchRequest<Day>(entityName: "Day")
    }

    @NSManaged public var date: Date?
    @NSManaged public var eventlink: NSSet?
    
    public var wrappedDate: Date {
        date ?? Date(timeIntervalSince1970: 0)
    }
    
    public var eventArray: [Events] {
        let set = eventlink as? Set<Events> ?? []
        return Array(set)
//        return set.sorted {
//            $0.wrappedDate < $1.wrappedDate
//        }
    }

}

// MARK: Generated accessors for eventlink
extension Day {

    @objc(addEventlinkObject:)
    @NSManaged public func addToEventlink(_ value: Events)

    @objc(removeEventlinkObject:)
    @NSManaged public func removeFromEventlink(_ value: Events)

    @objc(addEventlink:)
    @NSManaged public func addToEventlink(_ values: NSSet)

    @objc(removeEventlink:)
    @NSManaged public func removeFromEventlink(_ values: NSSet)

}

extension Day : Identifiable {

}
