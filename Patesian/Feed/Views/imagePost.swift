//
//  imageView.swift
//  PatesianAPI
//
//  Created by Jimin Lee on 17/02/2024.
//

import Foundation
import SwiftUI

struct imagePost: View {
    let content: String
    let user: String
    let group: String
    let date : Date
    let pfp: UIImage
    let image: UIImage
    @EnvironmentObject var settings: GameSettings
    
    
    var body: some View {
        
        VStack(spacing: 0)  {
            HStack(spacing: 10) {
                Image(uiImage: pfp.crop())
                    .resizable()
                    .scaledToFit()
                    .mask(Circle())
                    .frame(width: 40, height: 40)
                Text("\(user.lowercased())@\(group.lowercased())")
                    .font(.system(size: 15))
                    .bold()
                Spacer()
            }
            .padding(.leading)
            ZStack {
                Image(uiImage: image.crop())
                    .resizable()
                    .scaledToFit()
                Button(action: {
                    DispatchQueue.main.async {
                        //withAnimation {
                            settings.score = image
                        //}
                    }
                    
                }, label: {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "arrow.down.left.and.arrow.up.right.circle.fill")
                                .padding()
                                .foregroundStyle(.white)
                            
                        }
                    }
                    
                    
                })
            }
            .padding(.top, 6.0)
            HStack(spacing: 0)  {
                Text(content)
                    .font(.system(size: 15))
                
                Spacer()
            }.padding(.leading)
                .padding(.top, 10.0)
            
            HStack(spacing: 0) {
                Text("\(date.timeformat()) \t \(date.dateformat())")
                    .font(.system(size: 11))
                    .padding(.leading)
                    .padding(.top, 6.0)
                    .foregroundStyle(.gray)
                Spacer()
            }
            
            
        }
        
    }
}
