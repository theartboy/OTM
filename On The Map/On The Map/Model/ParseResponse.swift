//
//  ParseResponse.swift
//  On The Map
//
//  Created by John McCaffrey on 12/16/18.
//  Copyright © 2018 John McCaffrey. All rights reserved.
//

import Foundation

struct ParseResponse: Codable {
//    let statusCode: Int
//    let statusMessage: String
//    let underlyingError: String
//    let debugDescription: String
    
//    enum CodingKeys: String, CodingKey {
////        case statusCode = "status"
////        case statusMessage = "error"
//    }
    let stringValue: String
    let intValue: Int
    let underlyingError: String
}
extension ParseResponse: LocalizedError {
    var errorDescription: String? {
//        return statusMessage
        return stringValue
    }
}
