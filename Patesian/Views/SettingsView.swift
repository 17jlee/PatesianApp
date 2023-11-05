//
//  ContentView.swift
//  dataModel2
//
//  Created by Jimin Lee on 28/10/2023.
//

import SwiftUI
import Foundation
import CoreData


struct SettingsView: View {
    let persistenceController = PersistenceController.shared
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Day.entity(), sortDescriptors: []) var countries: FetchedResults<Day>
    
    func dateformat(date: Date) -> String {
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "EEEE, d MMMM y"
        return(formatter1.string(from: date))
    }
    
    func removeLanguages(at offsets: IndexSet) {
        //print(countries[offsets.first!])
        for index in offsets {
            let language = countries[index]
            print(language)
            moc.delete(language)
        }
        PersistenceController.shared.save()
    }
    
    func removeall() {
        for x in countries {
            moc.delete(x)
            
        }
        PersistenceController.shared.save()
    }
    
    func delete(entityName: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try persistenceController.container.viewContext.execute(deleteRequest)
        } catch let error as NSError {
            debugPrint(error)
        }
    }

    
    var body: some View {
        VStack {
//            List {
//                ForEach(countries, id: \.self) { country in
//                    Section(header: Text(country.wrappedFullName)) {
//                        ForEach(country.candyArray, id: \.self) { candy in
//                            Text(candy.wrappedName)
//                        }
//                    }
//                }
//            }
            Button("Clear") {
                
                    let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = Events.fetchRequest()
                      let batchDeleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
                    _ = try? persistenceController.container.viewContext.execute(batchDeleteRequest1)
                let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Day.fetchRequest()
                  let batchDeleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
                _ = try? persistenceController.container.viewContext.execute(batchDeleteRequest2)
                try? self.moc.save()
                //@FetchRequest(entity: Day.entity(), sortDescriptors: []) var countries: FetchedResults<Day>
                
                }
//            Button("Clear2") {
//                
//            }
//                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Day")
//                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//
//                do {
//                    try PersistenceController.shared.container.managedObjectModel.execute(deleteRequest, with: persistenceController.container.viewContext)
//                } catch let error as NSError {
//                    // TODO: handle the error
//                }
            }
        Button("debyg"){
            removeall()
        }
            Button("Print") {
                //print(Array(countries)[0].fullName)
                //@FetchRequest(entity: Day.entity(), sortDescriptors: []) var countries: FetchedResults<Day>
//                for x in countries {
//                    print(x.date)
//                    for y in Array(x.eventArray) {
//                        print(y.subject)
//                    }
//                }
                //print(countries.first?.date)
                    //print(Array(countries.first?.eventArray)
                      for x in countries {
                    print(x.date)
                          for y in x.eventArray {
                              print(y.location)
                          }
                }
            }
        
        List {
            ForEach(countries) { country in
                Text(dateformat(date:country.date!))
                
            }.onDelete(perform: removeLanguages)
        }
        
            
            Button("Add") {
                let candy1 = Events(context: self.moc)
                candy1.location = "E109"
                candy1.subject = "Computing"
                candy1.teacher = "Mr Read"
                candy1.start = Date.distantPast
                candy1.end = Date.distantFuture
                candy1.daylink = Day(context: self.moc)
                candy1.daylink?.date = Date.now
                
                let candy2 = Events(context: self.moc)
                candy2.location = "E111"
                candy2.subject = "Computifng"
                candy2.teacher = "Mr Reafd"
                candy2.start = Date.distantPast
                candy2.end = Date.distantFuture
                candy2.daylink = Day(context: self.moc)
                candy2.daylink?.date = Date.distantFuture
                
                let candy3 = Events(context: self.moc)
                candy3.location = "E113"
                candy3.subject = "Compuating"
                candy3.teacher = "Mr Regad"
                candy3.start = Date.distantPast
                candy3.end = Date.distantFuture
                candy3.daylink = Day(context: self.moc)
                candy3.daylink?.date = Date.now

                try? self.moc.save()
            }
        }

    }


#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
