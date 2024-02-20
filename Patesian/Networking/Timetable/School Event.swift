//
//  School Event.swift
//  Patesian
//
//  Created by Jimin Lee on 18/02/2024.
//

import Foundation


struct graphDate: Codable {
    var dateTime: Date
}

struct graphLocation: Codable {
    var displayName: String
}

struct schoolEventRaw: Codable {
    var subject: String
    var bodyPreview: String
    var start: graphDate
    var end: graphDate
    var location: graphLocation
}

struct graphResponse: Codable {
    var value: [schoolEventRaw]
}

struct schoolEvent: Hashable {
    var subject: String
    var teacher: String
    var location: String
    var start: Date
    var end: Date
}
