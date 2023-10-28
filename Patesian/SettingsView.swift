//
//  SettingsView.swift
//  Patesian
//
//  Created by Jimin Lee on 27/10/2023.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: loginSettings
    var body: some View {
        List {
            if settings.isAuthenticated {
                Button("Sign Out") {
                    MSALAuthentication.signout() { () in
                        settings.isAuthenticated = false
                        settings.graphResult = ""
                        settings.sortedData = [[Date: [schoolEvent]]]()
    //                    TimetableView.graphText = ""
    //                    TimetableView.graphResult = ""
                    }
                }
            }
            
        }
    }
}

#Preview {
    SettingsView()
}
