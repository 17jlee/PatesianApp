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
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var signedinuser: FetchedResults<SignedInUser>
    @State var cardVisible = false
    var body: some View {
        ZStack {
            
            Map() {
                
                Annotation("Pate's", coordinate: .pates) {
                    
                }
            }
            VStack {
                HStack {
                    if let loggedin = signedinuser.first {
                        Text("Good afternoon, \(loggedin.name!)")
                            .padding()
                            .font(.headline)
                            .bold()
                    }
                    else {
                        Text("Good afternoon")
                            .padding()
                            .font(.headline)
                            .bold()
                    }

                        
                        
                    Spacer()
                    Button {
                        Task {
                            cardVisible.toggle()
                            //try await print(resolveUsersTemplate())
                            //print(signedinuser.first!.name)
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
            
            
        }.popover(isPresented: $cardVisible, content: {
            NavigationStack{
                UserSettings()
                    .environmentObject(loginSettings())
                    .navigationTitle("Profile")
            }
            
            Button("Quit"){
                cardVisible.toggle()
            }
        })
        
        
    }
}

#Preview {
    MapView()
}
