//
//  UserDataResponse.swift
//  On The Map
//
//  Created by John McCaffrey on 12/17/18.
//  Copyright © 2018 John McCaffrey. All rights reserved.
//

import Foundation


struct UserEmail: Codable {
    let verified: Bool
    let code: Bool
    let address: String
    
    enum CodingKeys: String, CodingKey {
        case verified = "_verified"
        case code = "_verification_code_sent"
        case address = "address"
    }
}

struct UserResponse: Codable {
    let key: String
    let nickname: String
    let lastName: String
    let firstName: String
    
    enum CodingKeys: String, CodingKey {
        case key = "key"
        case nickname = "nickname"
        case lastName = "last_name"
        case firstName = "first_name"
        
    }

}
