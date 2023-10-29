//
//  SettingsView.swift
//  Patesian
//
//  Created by Jimin Lee on 27/10/2023.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: loginSettings
    @FetchRequest(sortDescriptors: []) var Items: FetchedResults<Item>
    var body: some View {
        List {
            
            Button("Print cache") {
                print("test")
                for x in Items{
                    print(x.savedData?.currentCache)
                }
                
            }
            if settings.isAuthenticated {
                Button("Sign Out") {
                    MSALAuthentication.signout() { () in
                        settings.isAuthenticated = false
                        settings.graphResult = ""
                        settings.sortedData = [[Date: [schoolEvent]]]()
                    }
                }
            }
            
        }
    }
}

#Preview {
    SettingsView()
}
