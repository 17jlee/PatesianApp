//
//  File.swift
//  
//
//  Created by Jimin Lee on 17/02/2024.
//

import Foundation
import SwiftUI

struct onePost: View {
    let content: String
    let user: String
    let group: String
    let date : Date
    let pfp: UIImage
    
    func dateformat(date: Date) -> String {
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "dd/MM/yy"
        return(formatter1.string(from: date))
    }
    
    func timeformat(date: Date) -> String {
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "HH:mm"
        return(formatter1.string(from: date))
    }
    
    
    var body: some View {
            HStack(alignment: .top) {
                VStack{
                    Image(uiImage: pfp.crop())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .mask{
                            Circle()
                        }
                }
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        
                        Text("\(user.lowercased())@\(group.lowercased())")
                            .font(.system(size: 15))
                            .bold()
                    }
                    HStack {
                        
                        Text(content)
                            .font(.system(size: 15))
                        
                        
                        Spacer()
                    }
                    HStack {
                        Text("\(timeformat(date:date))\t\(dateformat(date: date))")
                            .font(.system(size: 11))
                            .foregroundStyle(.gray)
                        Spacer()
                    }
                    
                    .padding(.top, 2)
                }
            }
            .frame(alignment: .top)
        
    }
}
