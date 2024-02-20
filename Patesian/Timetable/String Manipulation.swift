//
//  Lesson Label.swift
//  Patesian
//
//  Created by Jimin Lee on 18/02/2024.
//

import Foundation

func period(start: Date, end: Date) -> String {
    let combined = (start.timeformat(), end.timeformat())
    switch combined {
    case("08:40", "08:55") :
        return("AM Registration")
    case("09:00", "10:00") :
        return("Period 1")
    case("10:05", "11:05") :
        return("Period 2")
    case("11:35", "12:35") :
        return("Period 3")
    case("12:40", "13:40") :
        return("Period 4")
    case("14:40", "15:40") :
        return("Period 5")
    default :
        return("")
    
    }
}

func subjectGet(_ raw: String) -> String {
        if raw.contains(" - ") {
            let str = raw
            let teacherStart = str.range(of: " - ")!.upperBound
            let teacherEnd = str.endIndex

            let subjectEnd = str.range(of: " - ")!.lowerBound
            let subjectStart = str.startIndex
            let subjectRange = subjectStart..<subjectEnd

            let subjectSubstring = str[subjectRange]  // play
            
            return String(subjectSubstring)
        
    }
    else {
        return("")
    }
}

func teacherGet(_ raw: String) -> String {
        if raw.contains(" - ") {
            let str = raw
            let teacherStart = str.range(of: " - ")!.upperBound
            let teacherEnd = str.endIndex

            let subjectEnd = str.range(of: " - ")!.lowerBound
            let subjectStart = str.startIndex

            let teacherRange = teacherStart..<teacherEnd

            let teacherSubString = str[teacherRange]  // play
            
            return String(teacherSubString)
        
    }
    else {
        return("")
    }
}

