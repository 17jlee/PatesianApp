//
//  LoginView.swift
//  Patesian
//
//  Created by Jimin Lee on 15/10/2023.
//

import SwiftUI
import Foundation

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
    @State var cached = [[Date: [schoolEvent]]]()
    @State var sortedDict = [[Date : [[String : String]]].Element]()
    @State var listView = false
    //but heaven aint close in a place like this

    func removeall() {
        for x in CalendarDay {
            moc.delete(x)
        }
        PersistenceController.shared.save()
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
                            
                            //print(jsonData)
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
    

    
    

    

    
    
    func coredatawriter(currentResponse: graphResponse) {
        DispatchQueue.main.async {
            for x in Array(currentResponse.value) {
                let candy1 = Events(context: self.moc)
                candy1.location = subjectGet(x.location.displayName)
                candy1.subject = subjectGet(x.subject)
                candy1.teacher = teacherGet(x.subject)
                candy1.start = x.start.dateTime
                candy1.end = x.end.dateTime
                candy1.daylink = Day(context: self.moc)
                candy1.daylink?.date = x.start.dateTime.stripDate()
                
            }
            try? self.moc.save()
            cached  = cachedData(CalendarDay)
        }
    }
    
    
    
    var body: some View {
        VStack {
            
            ScrollViewReader{ proxy in
                Button("Jump to #50") {
                    withAnimation{
                        
                        proxy.scrollTo(Date.now.stripDate(), anchor: .top)
                    }
                    
                }
                
                List {
                    
                    ForEach(cached, id: \.self) { x in
                        Section(x.keys.first!.longdateformat()) {
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
                                            Text("\(eventObject.start.timeformat()) - \(eventObject.end.timeformat())")
                                        }
                                        

                                    }
                                }

                            }
                        }
                        
                        .id(x.keys.first!)
                    }
                }
                .onAppear() {
                    
                        withAnimation{
                            proxy.scrollTo(Date.now.stripDate(), anchor: .top)
                        }
                    
                }
                .onChange(of: cached){
                    print("changed")
                    print(cached)
                }
                .listStyle(.plain)
                    .navigationTitle("Timetable")
                    .toolbar {
                        ToolbarItem(placement: .automatic) {
                            Button {
                                listView.toggle()
                                //print(settings.sortedData)
                                //cached.append([Date.now : [schoolEvent(subject: "ff", teacher: "gg", location: "hh", start: Date.distantFuture, end: Date.distantPast)]])
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
                        DispatchQueue.main.async {
                            removeall()
                            login()
                            
                        } 
                    }
                    
            }
            
        }.onAppear() {
            print(cached.isEmpty)
                cached = cachedData(CalendarDay)
                
        }
        
    }
}

struct TimetableView_Previews: PreviewProvider {
  static var previews: some View {
    TimetableView()
          .environmentObject(loginSettings(previewing: true))
  }
}
