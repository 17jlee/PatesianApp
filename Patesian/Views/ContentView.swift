//
//  ContentView.swift
//  Patesian
//
//  Created by Jimin Lee on 10/10/2023.
//

import SwiftUI
import MapKit



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
                FriendsView()
                .navigationTitle("Friends")
                
            }.tabItem {
                Label("Friends", systemImage: "person.3")
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
