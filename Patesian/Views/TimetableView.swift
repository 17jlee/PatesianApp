//
//  LoginView.swift
//  Patesian
//
//  Created by Jimin Lee on 15/10/2023.
//

import SwiftUI
import Foundation

extension Color {
    static var patesRed: Color { Color(red: 0.78, green: 0.06, blue: 0.23) }
    static var patesRedAlt: Color {Color(red: 0.86, green: 0.03, blue: 0.08)}
}

@MainActor class loginSettings: ObservableObject {
    @Published var isAuthenticated = false
    @Published var sortedData = [[Date: [schoolEvent]]]()
    @Published var graphResult = ""
    @Published var jsonRaw = Data()
    
    init(previewing: Bool = false) {
            if previewing {
                var sortedData = [[Date: [schoolEvent]]]()
                var graphResult = ""
            }
        }

}

public class portableCache: NSObject {
    var currentCache = [Date : [schoolEvent]]()
}

struct schoolEvent: Hashable {
    var subject: String
    var teacher: String
    var location: String
    var start: Date
    var end: Date
}

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

struct TimetableView: View {
    let persistenceController = PersistenceController.shared
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Day.entity(), sortDescriptors: []) var CalendarDay: FetchedResults<Day>
    @EnvironmentObject var settings: loginSettings
    @State public var graphResult = ""
    @State private var accessTokenSource = ""
    @State private var showingAlert = false
    @State var currentResponse: graphResponse? = nil
    @State var graphText = ""
    @State var hurray = [Date : [[String : String]]]()
    @State var sortedDict = [[Date : [[String : String]]].Element]()
    @State var listView = false

    
    func stripDate(input: Date) -> Date {
        let strippedDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: input))
        return strippedDate!
    }
    
    func removeall() {
        for x in CalendarDay {
            moc.delete(x)
        }
        PersistenceController.shared.save()
    }
    
    func cachedData() -> [[Date: [schoolEvent]]] {
        var cachedCalendar = [[Date: [schoolEvent]]]()
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
        print(sortedArray)
        return sortedArray
    }
    
    func login() {
            MSALAuthentication.signin(completion: { securityToken, isTokenCached, expiresOn in
                if (isTokenCached != nil) && (expiresOn != nil)  {
                    DispatchQueue.main.async {
                        settings.isAuthenticated = true
                    }
                    accessTokenSource = "Access Token: \(isTokenCached! ? "Cached" : "Newly Acquired") Expires: \(expiresOn!)";
                    
                    guard let meUrl = URL(string: URLString()) else {
                        return
                    }
                    
                    var request = URLRequest(url: meUrl)
                    
                    request.httpMethod = "GET"
                    request.addValue("Bearer \(securityToken!)", forHTTPHeaderField: "Authorization")
                    
                    
                    URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, error == nil else {
                            //print(error!.localizedDescription)
                            return
                        }
                        
                        if let json = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers),
                           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                            DispatchQueue.main.async {
                                settings.graphResult = String(decoding: jsonData, as: UTF8.self)
                            }
                            DispatchQueue.main.async {
                                settings.jsonRaw = jsonData
                            }
                            jsonParser(json: jsonData)
                            print(jsonData)
                        } else {
                            print("An error has ocurred")
                        }
                    }).resume()
                }
                else {
                    showingAlert = true
                }
                
            })
        }
    
    
    func period(start: Date, end: Date) -> String {
        let combined = (timeformat(date: start), timeformat(date: end))
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
    
    func URLString() -> String {
        var URL = "https://graph.microsoft.com/v1.0/me/calendarview?startdatetime="
        URL.append(ISO8601DateFormatter().string(from: Date.now))
        URL.append("&enddatetime=")
        //let delta = Calendar.current.date(byAdding: .yearForWeekOfYear, value: 1, to: Date())
        let delta = Calendar.current.date(byAdding: .year, value: 1, to: Date())
        let deltaString = ISO8601DateFormatter().string(from: delta!)
        URL.append(deltaString)
        URL.append("&$top=2000")
        return URL
    }
    //https://graph.microsoft.com/v1.0/me/events?$select=subject,bodyPreview,start,end,location&$top=2002
    //https://graph.microsoft.com/v1.0/me/calendarview?startdatetime=2023-12-20T07:51:29.223Z&enddatetime=2024-12-27T07:51:29.223Z&$select=subject,bodyPreview,start,end,location&$top=2000
    
    
    func jsonParser(json: Data) -> [[Date: [schoolEvent]]]{
        let data = json
        //print(json)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        do {
            currentResponse = try decoder.decode(graphResponse.self, from: data)
            coredatawriter(currentResponse: currentResponse!)
            let result = (dictionaryInit(currentResponse: currentResponse!)).sorted {
                                            $0.0 < $1.0
                                        }
            var surt = [[Date: [schoolEvent]]]()
            for x in result {
                surt.append([x.key : x.value])
                
            }
            
            DispatchQueue.main.async {
                settings.sortedData = surt
            }
            
            
            return surt
        } catch {
            print(String(describing: error))
            return ([[Date.now : [schoolEvent(subject: "", teacher: "", location: "", start: Date.now, end: Date.now)]]])
        }
        
    }
    
    func subjectGet(raw: String) -> String {
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
    
    func teacherGet(raw: String) -> String {
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
    
    func timeformat(date: Date) -> String {
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "HH:mm"
        return(formatter1.string(from: date))
    }
    
    func dateformat(date: Date) -> String {
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "EEEE, d MMMM y"
        return(formatter1.string(from: date))
    }

    func dictionaryInit(currentResponse: graphResponse) -> [Date : [schoolEvent]] {
        var dictionaryStruct = [Date : [schoolEvent]]()
        for x in Array(currentResponse.value) {
            if dictionaryStruct[stripDate(input: x.start.dateTime)] == nil {
                dictionaryStruct[stripDate(input: x.start.dateTime)] = [schoolEvent(subject: subjectGet(raw: x.subject), teacher: teacherGet(raw: x.subject), location: subjectGet(raw: x.location.displayName), start: x.start.dateTime, end: x.end.dateTime)]
            }
            else {
                dictionaryStruct[stripDate(input: x.start.dateTime)]!.append(schoolEvent(subject: subjectGet(raw: x.subject), teacher: teacherGet(raw: x.subject), location: subjectGet(raw: x.location.displayName), start: x.start.dateTime, end: x.end.dateTime))
            }
            
        }

        return dictionaryStruct
    }
    
    func coredatawriter(currentResponse: graphResponse) {
        for x in Array(currentResponse.value) {
            let candy1 = Events(context: self.moc)
            candy1.location = subjectGet(raw: x.location.displayName)
            candy1.subject = subjectGet(raw: x.subject)
            candy1.teacher = teacherGet(raw: x.subject)
            candy1.start = x.start.dateTime
            candy1.end = x.end.dateTime
            candy1.daylink = Day(context: self.moc)
            candy1.daylink?.date = stripDate(input: x.start.dateTime)
            
            for x in Array(currentResponse.value) {
                print("hu")
                let candy1 = Events(context: self.moc)
                candy1.location = subjectGet(raw: x.location.displayName)
                candy1.subject = subjectGet(raw: x.subject)
                candy1.teacher = teacherGet(raw: x.subject)
                candy1.start = x.start.dateTime
                candy1.end = x.end.dateTime
                candy1.daylink = Day(context: self.moc)
                candy1.daylink?.date = stripDate(input: x.start.dateTime)
                
            }
        }
        PersistenceController.shared.save()
        
        
        
        //print(currentResponse)
    }
    
    
    
    var body: some View {
        VStack {
            List {
                
                ForEach(cachedData(), id: \.self) { x in
                    Section(dateformat(date: x.keys.first!)) {
                        ForEach(x[x.keys.first!]!, id: \.self) { eventObject in
                            HStack {

                                RoundedRectangle(cornerRadius: 50)
                                    .fill(Color.patesRed)
                                    .frame(width: 4, height: 40)
                                VStack {
                                    HStack {
                                        Text("\(String(eventObject.subject))")
                                            .font(Font.headline.weight(.bold))
                                        Spacer()
                                    }

                                    HStack {
                                        if String(eventObject.location) == "" && String(eventObject.teacher) == "" {
                                            Text("")
                                                .padding(.bottom, 3)
                                        }
                                        else if String(eventObject.location) == "" {
                                            Text("\(eventObject.teacher)")
                                                .font(Font.headline.weight(.light))
                                        }
                                        else {
                                            Text("\(String(eventObject.location)) - \(String(eventObject.teacher))")
                                                .font(Font.headline.weight(.light))
                                        }
                                        
                                        Spacer()
                                    }
                                    
                                }

                                Spacer()
                                VStack {
                                    HStack {
                                        Spacer()
                                        Text("\(period(start: eventObject.start, end:eventObject.end))")
                                    }
                                    HStack {
                                        Spacer()
                                        Text("\(String(timeformat(date: eventObject.start))) - \(String(timeformat(date: eventObject.end)))")
                                    }
                                    

                                }
                            }

                        }
                    }
                }
            }
            .listStyle(.plain)
                .navigationTitle("Timetable")
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button {
                            listView.toggle()
                            print(settings.jsonRaw)
                        } label: {
                            if listView {
                                Image(systemName: "calendar")
                            }
                            else {
                                Image(systemName: "calendar.day.timeline.left")
                            }
                        }
                    }

                }
                .alert(isPresented: $showingAlert) {
                            Alert(title: Text("Error"), message: Text("Unable to authenticate"), dismissButton: .default(Text("OK")))
                        }
                .refreshable {
                    print("Refreshing")
                    //let queue = DispatchQueue(label: "my-queue", qos: .userInteractive)
//                    queue.async {
//                        removeall()
//                    }
//                    queue.async {
//                        login()
//                    }
                    login()
                    
                    
                }
//                }.task {
//                    do {
//                        try await login()
//                        print(settings.jsonRaw)
//                    } catch {
//                        print("error")
//                    }

                .onAppear() {
                        //login()
                        //print(settings.jsonRaw)
                        //jsonParser(json: settings.jsonRaw)
                    
                    
                }
        }
        
    }
}

struct TimetableView_Previews: PreviewProvider {
  static var previews: some View {
    TimetableView()
          .environmentObject(loginSettings(previewing: true))
  }
}
