//
//  EventView.swift
//  Patesian
//
//  Created by Jimin Lee on 27/10/2023.
//

import Foundation
import SwiftUI

struct EventView: View {
    var body: some View {
        List {
            Text("Computing Society")
            Text("MedSoc")
            Text("Taylor Swift Soc")
            Text("Debate Soc")
            Text("School Council")
            Text("House Dance")
        }
    }
}


struct EventView_Previews: PreviewProvider {
  static var previews: some View {
    EventView()
  }
}
