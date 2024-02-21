//
//  JSON Parser.swift
//  Patesian
//
//  Created by Jimin Lee on 18/02/2024.
//

import Foundation


func jsonParser(json: Data) -> (dictionary: [[Date: [schoolEvent]]], graph: graphResponse){
    let data = json
    var currentResponse: graphResponse? = nil
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(dateFormatter)
    do {
        currentResponse = try decoder.decode(graphResponse.self, from: data)
        //coredatawriter(currentResponse: currentResponse!)
        let result = (dictionaryInit(currentResponse: currentResponse!)).sorted {
                                        $0.0 < $1.0
                                    }
        var surt = [[Date: [schoolEvent]]]()
        for x in result {
            surt.append([x.key : x.value])
            
        }
        return (dictionary: surt, graph: currentResponse!)
        
    } catch {
        print(String(describing: error))
        return (dictionary: [[Date.now : [schoolEvent(subject: "", teacher: "", location: "", start: Date.now, end: Date.now)]]], graph: graphResponse(value: [schoolEventRaw(subject: "", bodyPreview: "", start: graphDate(dateTime: Date.now), end: graphDate(dateTime: Date.now), location: graphLocation(displayName: ""))]))
    }
    
}
