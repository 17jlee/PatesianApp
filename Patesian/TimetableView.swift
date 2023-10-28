//
//  LoginView.swift
//  Patesian
//
//  Created by Jimin Lee on 15/10/2023.
//

import SwiftUI
import Foundation
import Combine

extension Color {
    static var patesRed: Color { Color(red: 0.78, green: 0.06, blue: 0.23) }
    static var patesRedAlt: Color {Color(red: 0.86, green: 0.03, blue: 0.08)}
}

@MainActor class loginSettings: ObservableObject {
    @Published var isAuthenticated = false
    @Published var sortedData = [[Date: [schoolEvent]]]()
    @Published var graphResult = ""
    
    init(previewing: Bool = false) {
            if previewing {
                var sortedData = [[Date: [schoolEvent]]]()
                var graphResult = ""
            }
        }

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
    @EnvironmentObject var settings: loginSettings
    @State public var graphResult = ""
    @State private var accessTokenSource = ""
    @State private var showingAlert = false
    @State var currentResponse: graphResponse? = nil
    @State var graphText = ""
    @State var hurray = [Date : [[String : String]]]()
    @State var sortedDict = [[Date : [[String : String]]].Element]()
    @State var sortbruh = [[Date : [[String : String]]]]()
    @State var listView = false
    //@State var sortedData = [[Date: [schoolEvent]]]()
    
    func fixesEverything1(trash: [[Date: [schoolEvent]].Element]) ->  [[Date: [schoolEvent]]] {
        var surt = [[Date: [schoolEvent]]]()
        for x in trash {
            //let dateNow = x.key
            surt.append([x.key : x.value])
        }
        return surt
    }
    
    func fixesEverything(trash: [[Date : [[String : String]]].Element]) ->  [[Date : [[String : String]]]] {
        var surt = [[Date : [[String : String]]]]()
        for x in trash {
            let dateNow = x.key
            surt.append([dateNow : x.value])
        }
        return surt
    }
    
    func stripDate(input: Date) -> Date {
        let strippedDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: input))
        return strippedDate!
    }
    
    func listmaker(currentResponse: graphResponse) {
        var array = [[String : Any]]()
        for x in Array(currentResponse.value) {
            let dict: [String : Any] = ["subject" : x.subject, "body" : x.bodyPreview, "start" : x.start.dateTime, "end" : x.end.dateTime, "location" : x.location.displayName]
            array.append(dict)
        }
    }
    
 func login()  {
        MSALAuthentication.signin(completion: { securityToken, isTokenCached, expiresOn in
            
            
            if (isTokenCached != nil) && (expiresOn != nil)  {
                DispatchQueue.main.async {
                    settings.isAuthenticated = true
                }
                
                //print(settings.isAuthenticated)
                //print("Auth status: \(settings.isAuthenticated)")
                //accessTokenSource = "Access Token: \(isTokenCached! ? "Cached" : "Newly Acquired") ";
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
                        
                        //print(type(of: jsonData))
                        jsonParser(json: jsonData)
                        //print(json)
                        //print("hoere")
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
        let combine = (timeformat(date: start), timeformat(date: end))
        switch combine {
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
        let delta = Calendar.current.date(byAdding: .weekOfYear, value: 3, to: Date())
        print (delta)
        let deltaString = ISO8601DateFormatter().string(from: delta!)
        URL.append(deltaString)
        URL.append("&$top=2000")
        return URL
    }
    //https://graph.microsoft.com/v1.0/me/events?$select=subject,bodyPreview,start,end,location&$top=2002
    //https://graph.microsoft.com/v1.0/me/calendarview?startdatetime=2023-12-20T07:51:29.223Z&enddatetime=2024-12-27T07:51:29.223Z&$select=subject,bodyPreview,start,end,location&$top=2000
    
    
    func jsonParser(json: Data) {
        let data = json
        //print(json)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        do {
            currentResponse = try decoder.decode(graphResponse.self, from: data)
            part2(current: (try decoder.decode(graphResponse.self, from: data)))
            miseEnPlace1(currentResponse: try decoder.decode(graphResponse.self, from: data))
            funk(res: currentResponse!)
            //graphText = stringCreator(raw: currentResponse!)
        } catch {
            print(String(describing: error))
        }
    }
    
    func part2(current : graphResponse) {
        hurray = miseEnPlace(currentResponse: current)
        let result = hurray.sorted {
            $0.0 < $1.0
        }
        
        //print(Array(result)[0])
        //print(type(of: Array(result)[0]))
        sortbruh = fixesEverything(trash: result)
    }
    
    func subjectGet(raw: String) -> String {
        var graphString = ""
            if raw.contains(" - ") {
                let str = raw
                let teacherStart = str.range(of: " - ")!.upperBound
                let teacherEnd = str.endIndex

                let subjectEnd = str.range(of: " - ")!.lowerBound
                let subjectStart = str.startIndex

                let teacherRange = teacherStart..<teacherEnd
                let subjectRange = subjectStart..<subjectEnd

                let teacherSubString = str[teacherRange]  // play
                let subjectSubstring = str[subjectRange]  // play
                
                return String(subjectSubstring)
            
        }
        else {
            return("")
        }
    }
    
    func teacherGet(raw: String) -> String {
        var graphString = ""
            if raw.contains(" - ") {
                let str = raw
                let teacherStart = str.range(of: " - ")!.upperBound
                let teacherEnd = str.endIndex

                let subjectEnd = str.range(of: " - ")!.lowerBound
                let subjectStart = str.startIndex

                let teacherRange = teacherStart..<teacherEnd
                let subjectRange = subjectStart..<subjectEnd

                let teacherSubString = str[teacherRange]  // play
                let subjectSubstring = str[subjectRange]  // play
                
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
    
    func converter(data: [[Date : [[String : String]]]]) -> [Date: [schoolEvent]] {
//        print("bruh")
        var output = [Date: [schoolEvent]]()
//        print(data.)
        for x in data {
            //print("\(x.keys[x.keys.startIndex])")
            var objectList = [schoolEvent]()
            for y in x.values.first! {
                //print("\(y) \n")
                //objectList.append(schoolEvent(subject: y["subject"]!, teacher: y["teacher"]!, location: y["location"]!, start: y["start"]!, end: y["end"]!))
            }
            //print(x.values)
//            print("keys")
        }
        return ([Date.now : [schoolEvent(subject: "", teacher: "", location: "", start: Date.now, end: Date.now)]])
    }
    
    func miseEnPlace(currentResponse: graphResponse) -> [Date : [[String : String]]] {
        var dictionaryStruct = [Date : [[String : String]]]()
        for x in Array(currentResponse.value) {
            if dictionaryStruct[stripDate(input: x.start.dateTime)] == nil {
                dictionaryStruct[stripDate(input: x.start.dateTime)] = [["subject" : subjectGet(raw: x.subject), "teacher": teacherGet(raw: x.subject),"start" : timeformat(date: x.start.dateTime), "end" : timeformat(date: x.end.dateTime), "location" : subjectGet(raw: x.location.displayName)]]
            }
            else {
                dictionaryStruct[stripDate(input: x.start.dateTime)]!.append(["subject" : subjectGet(raw: x.subject), "teacher": teacherGet(raw: x.subject),"start" : timeformat(date: x.start.dateTime), "end" : timeformat(date: x.end.dateTime), "location" : subjectGet(raw: x.location.displayName)])
            }
            
        }
        return dictionaryStruct
    }

    func miseEnPlace1(currentResponse: graphResponse) -> [Date : [schoolEvent]] {
        var dictionaryStruct = [Date : [schoolEvent]]()
        for x in Array(currentResponse.value) {
            if dictionaryStruct[stripDate(input: x.start.dateTime)] == nil {
                dictionaryStruct[stripDate(input: x.start.dateTime)] = [schoolEvent(subject: subjectGet(raw: x.subject), teacher: teacherGet(raw: x.subject), location: subjectGet(raw: x.location.displayName), start: x.start.dateTime, end: x.end.dateTime)]
            }
            else {
                dictionaryStruct[stripDate(input: x.start.dateTime)]!.append(schoolEvent(subject: subjectGet(raw: x.subject), teacher: teacherGet(raw: x.subject), location: subjectGet(raw: x.location.displayName), start: x.start.dateTime, end: x.end.dateTime))
            }
            
        }
        //print("\(dictionaryStruct) \n")
        return dictionaryStruct
    }
    
    func funk(res: graphResponse) {
        let result = (miseEnPlace1(currentResponse: res)).sorted {
                                        $0.0 < $1.0
                                    }
        DispatchQueue.main.async {
            settings.sortedData = fixesEverything1(trash: result)
        }
        
        for x in settings.sortedData {
            //print(x)
        }
    }
    
    
    
    var body: some View {

        
        
        VStack {
            List {
                ForEach(settings.sortedData, id: \.self) { x in
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
                                            //Spacer()
                                        }
                                        else if String(eventObject.location) == "" {
                                            Text("\(eventObject.teacher))")
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
                            //print(settings.isAuthenticated)
                        } label: {
                            
                            // your button label here
                            if listView {
                                Image(systemName: "calendar")
                            }
                            else {
                                Image(systemName: "calendar.day.timeline.left")
                            }


                        }
                    }

                }
                .refreshable {
                    print("Refreshing")
                }
                .onAppear() {

                    login()

                    for x in settings.sortedData {
                        print("\(x.keys.first)")
                        for y in x[x.keys.first!]! {
                            print("\(y) \n")
                        }
                    }
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
