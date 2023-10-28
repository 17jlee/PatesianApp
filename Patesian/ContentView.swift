//
//  ContentView.swift
//  Patesian
//
//  Created by Jimin Lee on 10/10/2023.
//

import SwiftUI
import MapKit

struct Location: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

extension CLLocationCoordinate2D {
    static let pates = CLLocationCoordinate2D(latitude: 51.9064680171035, longitude: -2.1159158133789875)
}

struct MapView: View {
    var body: some View {
        Map() {
            Annotation("Pate's", coordinate: .pates) {
                
            }
        }
    }
}

struct SettingsView1: View {
    var body: some View {
        Text("Websites")
    }
    
}




struct ContentView: View {
    @StateObject var settings = loginSettings()
    var body: some View {
        TabView {
            NavigationStack {
                MapView()
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }
            
            NavigationStack {
                TimetableView()
                .navigationTitle("Timetable")
                
                
            }
            .environmentObject(settings)
            .tabItem {
                Label("Timetable", systemImage: "calendar")
            }
            
            NavigationStack {
                NewsView()
                .navigationTitle("News")
                
            }.tabItem {
                Label("News", systemImage: "newspaper")
            }
            
            NavigationStack {
                EventView()
                    .navigationTitle("Events")
            }
                .tabItem {
                    Label("Events", systemImage: "clock")
                }
            
            
            
            
            NavigationStack {
                SettingsView()
            }
            .environmentObject(settings)
            
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }

    }
}

struct ContentView_Previews: PreviewProvider {
   // @StateObject var settings = loginSettings()
  static var previews: some View {
    ContentView()
          .environmentObject(loginSettings(previewing: true))
      
  }
    
}
