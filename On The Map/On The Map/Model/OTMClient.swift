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
//        static var accountId = 0 // not currently implemented on the site yet, thus it just needs something for now
        static var sessionKey = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let baseParse = "https://parse.udacity.com/parse/classes/StudentLocation"
        static let baseUdacity = "https://onthemap-api.udacity.com/v1/"

        case postSession
        case postStudentLocation
        case putStudentLocation(String)
        case getStudentLocation(String)
        case getStudentLocations
        case logout
        case login
        case getUserData
        case webSignup

        var stringValue: String {
            switch self {
            case .postSession: return ""
            case .postStudentLocation: return Endpoints.baseParse
            case .putStudentLocation(let objectId): return Endpoints.baseParse + objectId
            case .getStudentLocation(let uniqueKey): return Endpoints.baseParse + "?where=%7B%22uniqueKey%22%3A%22\(uniqueKey)%22%7D"
            case .getStudentLocations: return Endpoints.baseParse + "?limit=100&order=updatedAt"
            case .getUserData: return Endpoints.baseUdacity + "users/" + Auth.sessionKey
            case .logout: return Endpoints.baseUdacity + "session"
                
            case .login: return Endpoints.baseUdacity + "session"
            case .webSignup: return "https://auth.udacity.com/sign-up"
            }
        }
    
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    //MARK: methods


    class func logout (completion: @escaping(Bool, Error?)->Void) {
        Auth.sessionId = ""
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
//            if error != nil { // Handle error…
//                return
//            }
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
        //TODO: wrap with completion handler so it can logout on any screen and segue back to loginVC
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
                print("user: \(userProfile.firstName) \(userProfile.lastName)")

                DispatchQueue.main.async {
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
                Auth.sessionKey = response.account.key
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

    class func getStudentLocations(completion: @escaping (Bool, Error?) -> Void) {
        taskforGETRequest(url: Endpoints.getStudentLocations.url, responseType: LocationResponse.self, errorType: ParseResponse.self) { (response, error) in
            if let response = response {
                print("it is good")
                DispatchQueue.main.async {
                    StudentModel.students = response.results
                    completion(true, nil)
                }
            } else {
                print("it is bad\(String(describing: error))")
                completion(false, error)
            }
        }

    }

    @discardableResult class func taskforGETRequest<ResponseType: Decodable, ErrorType: Decodable> (url: URL, responseType: ResponseType.Type, errorType: ErrorType.Type, completion: @escaping (ResponseType?, Error?)->Void)->URLSessionTask{
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
        var request = URLRequest(url: url)
//        print("url: \(url)")
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
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


//    class func getRequestToken(completion: @escaping (Bool, Error?) -> Void) {
//        taskforGETRequest(url: Endpoints.getRequestToken.url, responseType: RequestTokenResponse.self) { (response, error) in
//            if let response = response {
//                Auth.requestToken = response.requestToken
//                completion(true,nil)
//            } else {
//                completion(false,error)
//            }
//        }
//        //        let task = URLSession.shared.dataTask(with: Endpoints.getRequestToken.url) { data, response, error in
//        //            guard let data = data else {
//        //                completion(false, nil)
//        //                return
//        //            }
//        //            let decoder = JSONDecoder()
//        //            do {
//        //                let responseObject = try decoder.decode(RequestTokenResponse.self, from: data)
//        ////                print(responseObject.requestToken)
//        //                Auth.requestToken = responseObject.requestToken
//        //                completion(true, nil)
//        //            } catch {
//        //                completion(false, nil)
//        //            }
//        //         }
//        //        task.resume()
//    }
//
//    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
//        taskforGETRequest(url: Endpoints.getWatchlist.url, responseType: MovieResults.self) { (response, error) in
//            if let response = response {
//                completion(response.results, nil)
//            } else {
//                completion([], error)
//            }
//        }
//
//        //        let task = URLSession.shared.dataTask(with: Endpoints.getWatchlist.url) { data, response, error in
//        //            guard let data = data else {
//        //                completion([], error)
//        //                return
//        //            }
//        //            let decoder = JSONDecoder()
//        //            do {
//        //                let responseObject = try decoder.decode(MovieResults.self, from: data)
//        //                completion(responseObject.results, nil)
//        //            } catch {
//        //                completion([], error)
//        //            }
//        //        }
//        //        task.resume()
//    }
//    class func search(query: String, completion: @escaping ([Movie], Error?) -> Void) ->URLSessionTask{
//        let task = taskforGETRequest(url: Endpoints.search(query).url, responseType: MovieResults.self) { response, error in
//            if let response = response {
//                completion(response.results, nil)
//            } else {
//                completion([], error)
//            }
//        }
//        return task
//    }
//    class func markWatchlist(movieId: Int, watchlist: Bool, completion: @escaping (Bool, Error?)->Void) {
//        let body = MarkWatchlist(mediaType: "movie", mediaId: movieId, watchlist: watchlist)
//        taskForPOSTRequest(url: Endpoints.markWatchList.url, responseType: TMDBResponse.self, body: body) { (response, error) in
//            if let response = response {
//                completion(response.statusCode==1 || response.statusCode==12 || response.statusCode == 13, nil)
//            } else {
//                print("mwl: \(String(describing: error))")
//                completion(false, error)
//            }
//        }
//    }
//    class func markFavorite(movieId: Int, favorite: Bool, completion: @escaping (Bool, Error?) -> Void) {
//        let body = MarkFavorite(mediaType: "movie", mediaId: movieId, favorite: favorite)
//        taskForPOSTRequest(url: Endpoints.markFavorite.url, responseType: TMDBResponse.self, body: body) { response, error in
//            if let response = response {
//                completion(response.statusCode == 1 || response.statusCode == 12 || response.statusCode == 13, nil)
//            } else {
//                completion(false, nil)
//            }
//        }
//    }
//    class func downloadPosterImage(path: String, completion: @escaping(Data?, Error?) -> Void) {
//        let task = URLSession.shared.dataTask(with: Endpoints.posterImageUrl(path).url){(data, response, error) in
//            DispatchQueue.main.async {
//                completion(data, error)
//            }
//        }
//        task.resume()
//
//    }
//
}
