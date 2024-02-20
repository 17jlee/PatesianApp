//
//  File.swift
//  
//
//  Created by Jimin Lee on 17/02/2024.
//

import Foundation
import SwiftUI
import PhotosUI

struct createPost: View {
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarImage: UIImage?
    @State private var imageData: Data?
    @State var content = ""
    var groups = ["pgscompsoc", "pgsd&acommitee", "york", "richmond"]
    @State private var selectedGroup = "pgscompsoc"
    
    func imagePostRequest(user: String, group: String, content: String, image: UIImage) -> URLRequest? {
        guard let imageData = image.pngData() else {
            // Handle error if unable to convert image to data
            print("unable to convert to png")
            return nil
        }
        guard let url = URL(string: "https://api.inertiablogs.com/posts") else {
            // Handle error if the URL is invalid
            print("invalid URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        let clrf = "\r\n"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)")
        body.append(clrf)
        body.append("Content-Disposition: form-data; name=\"postimage\"; filename=\"\(user)-\(group).png\"")
        body.append(clrf)
        body.append("Content-Type: image/png")
        body.append(clrf)
        body.append(clrf)
        body.append(imageData)
        body.append(clrf)
        body.append("--\(boundary)")
        body.append(clrf)
        body.append("Content-Disposition: form-data; name=\"user\"")
        body.append(clrf)
        body.append(clrf)
        body.append("\(user)")
        body.append(clrf)
        body.append("--\(boundary)")
        body.append(clrf)
        body.append("Content-Disposition: form-data; name=\"group\"")
        body.append(clrf)
        body.append(clrf)
        body.append("\(group)")
        body.append(clrf)
        body.append("--\(boundary)")
        body.append(clrf)
        body.append("Content-Disposition: form-data; name=\"content\"")
        body.append(clrf)
        body.append(clrf)
        body.append("\(content)")
        body.append(clrf)
        body.append("--\(boundary)--")
        body.append(clrf)
        
        request.httpBody = body
        
        return request
    }
    
    var body: some View {
        VStack {
            PhotosPicker(selection: $avatarItem, matching: .images) {
                Label("Attach an Image", systemImage: "photo")
            }
            
            if let image = avatarImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            
            TextField("Content", text: $content)
                .padding()
            HStack(spacing: 0) {
                Text("as 17jlee@")
                Picker("Select Group", selection: $selectedGroup) {
                                ForEach(groups, id: \.self) {
                                    Text($0)
                                }
                }.padding(.leading, -11.5   )
                //Spacer()
            }
            
            Button("Upload") {
                let request = imagePostRequest(user: "17jlee", group: "pgscompsoc", content: "Cafuné", image: avatarImage!)
                let task = URLSession.shared.dataTask(with: request!) { (data, response, error) in
                    // Handle the server response here
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        return
                    }

                    // Process the response data
                    if let data = data {
                        let responseString = String(data: data, encoding: .utf8)
                        print("Response: \(responseString ?? "")")
                    }
                }

                // Start the URLSession task
                task.resume()

                
                
            }
            
            
            
            
            
            //Text(title)
            
        }.onChange(of: avatarItem) { _ in
            Task {
                if let loaded = try? await avatarItem?.loadTransferable(type: Data.self) {
                    avatarImage = UIImage(data: loaded)
                    imageData = loaded
                } else {
                    print("Failed")
                }
            }
        }
        
        

        
        
    }
}
