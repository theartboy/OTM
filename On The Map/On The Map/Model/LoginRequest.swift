//
//  LoginRequest.swift
//  On The Map
//
//  Created by John McCaffrey on 12/16/18.
//  Copyright © 2018 John McCaffrey. All rights reserved.
//

import Foundation

struct LoginRequest: Codable {
    let username: String
    let password: String
    
    enum CodingKeys: String, CodingKey {
        case username
        case password
    }
}
