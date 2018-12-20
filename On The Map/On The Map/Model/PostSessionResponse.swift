//
//  PostSessionResponse.swift
//  On The Map
//
//  Created by John McCaffrey on 12/15/18.
//  Copyright © 2018 John McCaffrey. All rights reserved.
//

import Foundation

struct Account: Codable {
    let registered: Bool
    let key: String
}
struct Session: Codable {
    let id: String
    let expiration: String
}

struct PostSessionResponse: Codable {
    let account: Account
    let session: Session
}

