//
//  MapView.swift
//  Patesian
//
//  Created by Jimin Lee on 07/11/2023.
//

import Foundation
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
        ZStack {
            
            Map() {
                
                Annotation("Pate's", coordinate: .pates) {
                    
                }
            }
            VStack {
                HStack {
                    Text("Good afternoon, Sebastian")
                        .padding()
                        //.font(.title3)
                        .font(.headline)
                        
                        .bold()
                        //
                        
                        
                    Spacer()
                    Button {
                        Task {
                            try await print(resolveUsersTemplate())
                            print("here")
                        }
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .scaledToFill()
                            

                        
                    }.padding(.trailing)
                }
                .frame(maxWidth: .infinity)
                .background(.thinMaterial)
                Spacer()
                
            }
            
            
        }
        
        
    }
}

#Preview {
    MapView()
}
