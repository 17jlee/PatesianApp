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
    @State var rawResponse = ([[Date: [schoolEvent]]](), graphResponse(value: [schoolEventRaw(subject: "", bodyPreview: "", start: graphDate(dateTime: Date.now), end: graphDate(dateTime: Date.now), location: graphLocation(displayName: ""))]))
    //but heaven aint close in a place like this

    func clearAll() async {
        for x in CalendarDay {
            moc.delete(x)
        }
        PersistenceController.shared.save()
    }
    
    func coredatawriter(currentResponse: graphResponse) async {
            for x in Array(currentResponse.value) {
                let event = Events(context: self.moc)
                event.location = subjectGet(x.location.displayName)
                event.subject = subjectGet(x.subject)
                event.teacher = teacherGet(x.subject)
                event.start = x.start.dateTime
                event.end = x.end.dateTime
                event.daylink = Day(context: self.moc)
                event.daylink?.date = x.start.dateTime.stripDate()
                
            }
            try? self.moc.save()
            cached = cachedData(CalendarDay)
        
    }
    
    
    
    var body: some View {
        VStack {
            
//            Button("print api") {
//                print(settings.graphResult)
//            }
            
            ScrollViewReader{ proxy in
//                Button("Jump to #50") {
//                    withAnimation{
//                        
//                        proxy.scrollTo(Date.now.stripDate(), anchor: .top)
//                    }
//                    
//                }
                
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
                            
                        }
                    Task {
                        
                            cached = cachedData(CalendarDay)
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
                                Task {
                                    await clearAll()
                                }
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
                            Task {
                                await clearAll()
                                try await rawResponse = jsonParser(json: login(using: settings, endpoint: URLString()))
                                cached = rawResponse.0
                                await coredatawriter(currentResponse: rawResponse.1)
                            }
                            
                            
                        } 
                    
                    
            }
            
        }.onAppear() {
            print(cached.isEmpty)
                //cached = cachedData(CalendarDay)
                
        }
        
    }
}

struct TimetableView_Previews: PreviewProvider {
  static var previews: some View {
    TimetableView()
          .environmentObject(loginSettings(previewing: true))
  }
}
