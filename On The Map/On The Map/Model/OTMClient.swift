//
//  OTMClient.swift
//  On The Map
//
//  Created by John McCaffrey on 12/14/18.
//  Copyright © 2018 John McCaffrey. All rights reserved.
//

import Foundation

class OTMClient {
    
    static let apiKey = "91fcf4d7c9405128220d9e2ef079a9e9"//REMOVE
    
    static let parseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let RESTApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    struct Auth {
        static var accountKey = ""
        static var sessionId = ""
        static var putOrPost = ""
        static var userFirstName = ""
        static var userLastName = ""
        static var objId = ""
    }
    
    enum Endpoints {
        static let baseParse = "https://parse.udacity.com/parse/classes/StudentLocation"
        static let baseUdacity = "https://onthemap-api.udacity.com/v1/"

        case postSession
        case postStudentLocation
        case putStudentLocation
        case getStudentLocation
        case getStudentLocations
        case logout
        case login
        case getUserData
        case webSignup

        var stringValue: String {
            switch self {
            case .postSession: return ""
            case .postStudentLocation: return Endpoints.baseParse
            case .putStudentLocation: return Endpoints.baseParse + "/" + Auth.objId
            case .getStudentLocation: return Endpoints.baseParse + "?where=%7B%22uniqueKey%22%3A%22" + Auth.accountKey + "%22%7D"
            case .getStudentLocations: return Endpoints.baseParse + "?limit=100&order=updatedAt"
            case .getUserData: return Endpoints.baseUdacity + "users/" + Auth.accountKey
            case .logout: return Endpoints.baseUdacity + "session"
                
            case .login: return Endpoints.baseUdacity + "session"
            case .webSignup: return "https://auth.udacity.com/sign-up"
            }
        }
    
        var url: URL {
            return URL(string: stringValue)!
        }
    }


    class func logout (completion: @escaping(Bool, Error?)->Void) {
        Auth.sessionId = ""
        Auth.objId = ""
        var request = URLRequest(url: Endpoints.logout.url)
            //URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false,error)
                }
                return
            }
            let range = (5..<data.count)
            let newData = data.subdata(in: range) /* subset response data! */
            print(String(data: newData, encoding: .utf8)!)
            DispatchQueue.main.async {
                completion(true, nil)
            }
        }
        task.resume()
    }
    
    class func getUserData(completion: @escaping(Bool, Error?)->Void){
        let request = URLRequest(url: Endpoints.getUserData.url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false,error)
                }
                return
            }
            let range = (5..<data.count)
            let newData = data.subdata(in: range) /* subset response data! */
            //            print(String(data: newData, encoding: .utf8)!)
            let decoder = JSONDecoder()
            do {
                let userProfile = try decoder.decode(UserResponse.self, from: newData)

                DispatchQueue.main.async {
                    print("user: \(userProfile.firstName) \(userProfile.lastName)")
                    Auth.userFirstName = userProfile.firstName
                    Auth.userLastName = userProfile.lastName
                    print("does \(self.Auth.accountKey) ?? \(userProfile.key)")
                    completion(true, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(UdacityResponse.self, from: newData)
                    DispatchQueue.main.async {
                        completion(false, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(false, error)
                    }
                }
            }
        }
        task.resume()
    }
    
    class func login(username: String, password: String, completion: @escaping (Bool, Error?)->Void){
        let bodyItem = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)

        taskForPOSTRequest(url: Endpoints.login.url, responseType: PostSessionResponse.self, errorType: UdacityResponse.self, body: bodyItem!) { (response, error) in
            if let response = response {
                Auth.sessionId = response.session.id
                Auth.accountKey = response.account.key
                completion(true, nil)
            } else {
                completion(false,error)
            }
        }
    }
    
    
    class func taskForPOSTRequest<ResponseType: Decodable, ErrorType: Decodable>(url: URL, responseType: ResponseType.Type, errorType: ErrorType.Type, body: Data, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        print(request)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil,error)
                }
                return
            }
            let range = (5..<data.count)
            let newData = data.subdata(in: range) /* subset response data! */
            //            print(String(data: newData, encoding: .utf8)!)
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorType.self, from: newData)
                    DispatchQueue.main.async {
                        completion(nil, errorResponse as? Error)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
    }

    
    class func postNewLocation(locationName: String, mediaURL: String, lat: Double, lon: Double, completion: @escaping (Bool, Error?)->Void){
        let bodyItem = "{\"uniqueKey\": \"\(Auth.accountKey)\", \"firstName\": \"\(Auth.userFirstName)\", \"lastName\": \"\(Auth.userLastName)\",\"mapString\": \"\(locationName)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(lat), \"longitude\": \(lon)}"
        var request = URLRequest(url: Endpoints.postStudentLocation.url)
        print(bodyItem)
        
        request.httpMethod = "POST"
        request.addValue(parseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(RESTApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyItem.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    print("help")
                    completion(false,error)
                }
                return
            }
            print(String(data: data, encoding: .utf8)!)
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(PostStudentLocationResponse.self, from: data)
                DispatchQueue.main.async {
                    print(String(data: data, encoding: .utf8)!)
                    print("RespObj POST: \(responseObject)")
                    Auth.objId = responseObject.objectId
                    completion(true, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ParseResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(false, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(false, error)
                    }
                }
            }
        }
        task.resume()
    }
    class func putNewLocation(locationName: String, mediaURL: String, lat: Double, lon: Double, completion: @escaping (Bool, Error?)->Void){
        let bodyItem = "{\"uniqueKey\": \"\(Auth.accountKey)\", \"firstName\": \"\(Auth.userFirstName)\", \"lastName\": \"\(Auth.userLastName)\",\"mapString\": \"\(locationName)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(lat), \"longitude\": \(lon)}"
        var request = URLRequest(url: Endpoints.putStudentLocation.url)
        
        request.httpMethod = "PUT"
        request.addValue(parseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(RESTApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyItem.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false,error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(PutStudentLocationResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ParseResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(false, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(false, error)
                    }
                }
            }
        }
        task.resume()
    }

    class func getStudentLocations(completion: @escaping (Bool, Error?) -> Void) {
        taskforGETRequest(url: Endpoints.getStudentLocations.url, responseType: LocationResponse.self, errorType: ParseResponse.self) { (response, error) in
            if let response = response {
                DispatchQueue.main.async {
                    StudentModel.students = response.results
                    completion(true, nil)
                }
            } else {
                completion(false, error)
            }
        }
        
    }
    class func getStudentLocation(completion: @escaping (Bool, Error?) -> Void) {
        taskforGETRequest(url: Endpoints.getStudentLocation.url, responseType: LocationResponse.self, errorType: ParseResponse.self) { (response, error) in
            if let response = response {
                 DispatchQueue.main.async {
                    if response.results.count == 0 {
                        completion(false, nil)
                    } else {
                        print("location record found")
                        print("location objId: \(response.results[0].objectId)")
                        Auth.objId = response.results[0].objectId
                        completion(true, nil)
                    }
 
                }
            } else {
                print("location error: \(String(describing: error))")
                completion(false, error)
            }
        }
        
    }

    @discardableResult class func taskforGETRequest<ResponseType: Decodable, ErrorType: Decodable> (url: URL, responseType: ResponseType.Type, errorType: ErrorType.Type, completion: @escaping (ResponseType?, Error?)->Void)->URLSessionTask{
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
        var request = URLRequest(url: url)
//        print("url: \(url)")
        request.addValue(parseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(RESTApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
//            print(String(data: data, encoding: .utf8)!)

           let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
//                print("do: \(responseObject)")
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    
                    print("do catch do:  \(String(data: data, encoding: .utf8)!)")
                    let errorResponse = try decoder.decode(ErrorType.self, from: data)
                    print("error getFunc: \(errorResponse)")
                    DispatchQueue.main.async {
                        completion(nil, errorResponse as? Error)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        return task
    }


}
