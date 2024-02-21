//
//  Timetable.swift
//  Patesian
//
//  Created by Jimin Lee on 18/02/2024.
//

import Foundation

@MainActor class loginSettings: ObservableObject {
    @Published var isAuthenticated = false
    @Published var sortedData = [[Date: [schoolEvent]]]()
    @Published var graphResult = ""
    @Published var jsonRaw = Data()
    @Published var accessTokenSource = ""
    @Published var showingAlert = false
    
    init(previewing: Bool = false) {
            if previewing {
                var sortedData = [[Date: [schoolEvent]]]()
                var graphResult = ""
            }
        }

}
