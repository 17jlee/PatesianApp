//
//  ResolveCache.swift
//  Patesian
//
//  Created by Jimin Lee on 18/02/2024.
//

import Foundation
import SwiftUI

func cachedData(_ CalendarDay: FetchedResults<Day>) -> [[Date: [schoolEvent]]] {
    var cachedDay = [Date : [schoolEvent]]()
    var sortedArray = [[Date: [schoolEvent]]]()
    for x in CalendarDay {
        var schoolEventArray = [schoolEvent]()
        for y in x.eventArray {
            schoolEventArray.append(schoolEvent(subject: y.subject!, teacher: y.teacher!, location: y.location!, start: y.start!, end: y.end!))
        }
        cachedDay[x.date!] = schoolEventArray.sorted(by: { $0.start.compare($1.start) == .orderedAscending} )
    }
    let result = cachedDay.sorted {
                                    $0.0 < $1.0
                                }
    for x in result {
        sortedArray.append([x.key : x.value])
        
    }
    //print(sortedArray)
    return sortedArray
}


