//
//  File.swift
//  
//
//  Created by Jimin Lee on 17/02/2024.
//

import Foundation

extension Data {
   mutating func append(_ string: String) {
      if let data = string.data(using: .utf8) {
         append(data)
      }
   }
}
