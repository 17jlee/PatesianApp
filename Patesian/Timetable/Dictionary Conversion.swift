//
//  Dictionary Conversion.swift
//  Patesian
//
//  Created by Jimin Lee on 18/02/2024.
//

import Foundation

func dictionaryInit(currentResponse: graphResponse) -> [Date : [schoolEvent]] {
    var dictionaryStruct = [Date : [schoolEvent]]()
    for x in Array(currentResponse.value) {
        if dictionaryStruct[x.start.dateTime.stripDate()] == nil {
            dictionaryStruct[x.start.dateTime.stripDate()] = [schoolEvent(subject: subjectGet( x.subject), teacher: teacherGet(x.subject), location: subjectGet(x.location.displayName), start: x.start.dateTime, end: x.end.dateTime)]
        }
        else {
            dictionaryStruct[x.start.dateTime.stripDate()]!.append(schoolEvent(subject: subjectGet( x.subject), teacher: teacherGet(x.subject), location: subjectGet(x.location.displayName), start: x.start.dateTime, end: x.end.dateTime))
        }
        
    }

    return dictionaryStruct
}
