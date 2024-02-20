//
//  Endpoint.swift
//  Patesian
//
//  Created by Jimin Lee on 18/02/2024.
//

import Foundation

func URLString() -> String {
    var URL = "https://graph.microsoft.com/v1.0/me/calendarview?startdatetime="
    let backdelta = Calendar.current.date(byAdding: .year, value: -1, to: Date())
    URL.append(ISO8601DateFormatter().string(from: backdelta!))
    URL.append("&enddatetime=")
    let delta = Calendar.current.date(byAdding: .year, value: 1, to: Date())
    let deltaString = ISO8601DateFormatter().string(from: delta!)
    URL.append(deltaString)
    URL.append("&$top=2000")
    return URL
}
