//
//  ParseResponse.swift
//  On The Map
//
//  Created by John McCaffrey on 12/16/18.
//  Copyright © 2018 John McCaffrey. All rights reserved.
//

import Foundation

struct ParseResponse: Codable {

    let stringValue: String
    let intValue: Int
    let underlyingError: String
    let debugDescription: String
}
extension ParseResponse: LocalizedError {
    var errorDescription: String? {
        return stringValue
    }
}
