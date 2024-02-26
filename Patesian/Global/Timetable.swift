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

func uploadTimetable(_ timetable : [schoolEvent], username: String) async {
    let timetabledata = uploadTimetable(user: username, data: timetable)
    let url = URL(string: "https://api.inertiablogs.com/timetables")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .formatted(dateFormatter)
    let data = try! encoder.encode(timetabledata)
    print(data.base64EncodedString())
    do{
        let (_, response) = try await URLSession.shared.upload(for: request, from: data)
        print(response)
        
    }
    catch {
        print(error)
    }
    
}
