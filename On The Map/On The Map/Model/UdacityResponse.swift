//
//  UdacityResponse.swift
//  On The Map
//
//  Created by John McCaffrey on 12/16/18.
//  Copyright © 2018 John McCaffrey. All rights reserved.
//

import Foundation

struct UdacityResponse: Codable {
    let statusCode: Int
    let statusMessage: String
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "status"
        case statusMessage = "error"
    }
}
extension UdacityResponse: LocalizedError {
    var errorDescription: String? {
        return statusMessage
    }
}
