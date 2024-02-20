//
//  Events+CoreDataProperties.swift
//  dataModel2
//
//  Created by Jimin Lee on 04/11/2023.
//
//

import Foundation
import CoreData


extension Events {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Events> {
        return NSFetchRequest<Events>(entityName: "Events")
    }

    @NSManaged public var subject: String?
    @NSManaged public var teacher: String?
    @NSManaged public var location: String?
    @NSManaged public var start: Date?
    @NSManaged public var end: Date?
    @NSManaged public var daylink: Day?
    
    public var wrappedSubject: String {
        subject ?? "Unknown Subject"
    }
    public var wrappedTeacher: String {
        teacher ?? "Unknown Subject"
    }
    public var wrappedLocation: String {
        location ?? "Unknown Subject"
    }
    public var wrappedStart: Date {
        start ?? Date.distantPast
    }
    public var wrappedEnd: Date {
        end ?? Date.distantFuture
    }
    

}

extension Events : Identifiable {

}
