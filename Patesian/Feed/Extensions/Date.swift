//
//  File.swift
//  
//
//  Created by Jimin Lee on 17/02/2024.
//

import Foundation

extension Date {
    func dateformat() -> String {
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "dd/MM/yy"
        return(formatter1.string(from: self))
    }
    
    func timeformat() -> String {
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "HH:mm"
        return(formatter1.string(from: self))
    }
    
    func longdateformat() -> String {
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "EEEE, d MMMM y"
        return(formatter1.string(from: self))
    }
    
    func stripDate() -> Date {
        let strippedDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self))
        return strippedDate!
    }
}
