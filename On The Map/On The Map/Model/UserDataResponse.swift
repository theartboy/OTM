//
//  UserDataResponse.swift
//  On The Map
//
//  Created by John McCaffrey on 12/17/18.
//  Copyright © 2018 John McCaffrey. All rights reserved.
//

import Foundation

//struct User: Codable {
//    let firstName: String
//    let lastName: String
//    let websiteUrl: String
//    let location: String
//
//    enum CodingKeys: String, CodingKey {
//        case firstName = "first_name"
//        case lastName = "last_name"
//        case websiteUrl = "website_url"
//        case location
//    }
//
//}


//struct UserDataResponse: Codable {
//    let user: User
//}
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
//    let emailPreferences: Filler
//    let externalAccounts: [String]
//    let registered: Bool
    let key: String
//    let enrollments: [String]
//    let tags: [String]
//    let guardItem: Filler
    let nickname: String
//    let affiliateProfiles: [String]
//    let memberships: [String]
//    let hasPassword: Bool
//    let imageUrl: String
//    let badges: [String]
//    let employerSharing: Bool
//    let socialAccounts: [String]
    let lastName: String
//    let principals: [String]
    let firstName: String
//    let email: UserEmail
//    let cohortKeys: [String]
    
    enum CodingKeys: String, CodingKey {
//        case emailPreferences = "email_preferences"
//        case externalAccounts = "external_accounts"
//        case registered = "_registered"
        case key = "key"
//        case enrollments = "_enrollments"
//        case tags = "tags"
//        case guardItem = "guard"
        case nickname = "nickname"
//        case affiliateProfiles = "_affiliate_profiles"
//        case memberships = "_memberships"
//        case hasPassword = "_has_password"
//        case imageUrl = "_image_url"
//        case badges = "_badges"
//        case employerSharing = "employer_sharing"
//        case socialAccounts = "social_accounts"
        case lastName = "last_name"
//        case principals = "_principals"
        case firstName = "first_name"
//        case email = "email"
//        case cohortKeys = "_cohort_keys"
        
    }

}
