//
//  ParseErrorHandlingController.swift
//  On The Map
//
//  Created by John McCaffrey on 12/16/18.
//  Copyright © 2018 John McCaffrey. All rights reserved.
//

import Foundation
import UIKit

// https://docs.parseplatform.org/ios/guide/#sessions

//class ParseErrorHandlingController {
//    class func handleParseError(error: NSError) {
//        if error.domain != PFParseErrorDomain {
//            return
//        }
//        
//        switch (error.code) {
//        case kPFErrorInvalidSessionToken:
//            handleInvalidSessionTokenError()
//                
//            ... // Other Parse API Errors that you want to explicitly handle.
//        }
//        
//        private class func handleInvalidSessionTokenError() {
//            //--------------------------------------
//            // Option 1: Show a message asking the user to log out and log back in.
//            //--------------------------------------
//            // If the user needs to finish what they were doing, they have the opportunity to do so.
//            //
//            // let alertView = UIAlertView(
//            //   title: "Invalid Session",
//            //   message: "Session is no longer valid, please log out and log in again.",
//            //   delegate: nil,
//            //   cancelButtonTitle: "Not Now",
//            //   otherButtonTitles: "OK"
//            // )
//            // alertView.show()
//            
//            //--------------------------------------
//            // Option #2: Show login screen so user can re-authenticate.
//            //--------------------------------------
//            // You may want this if the logout button is inaccessible in the UI.
//            //
//            // let presentingViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
//            // let logInViewController = PFLogInViewController()
//            // presentingViewController?.presentViewController(logInViewController, animated: true, completion: nil)
//        }
//    }
//    
//    // In all API requests, call the global error handler, e.g.
//    let query = PFQuery(className: "Object")
//    query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
//    if error == nil {
//    // Query Succeeded - continue your app logic here.
//    } else {
//    // Query Failed - handle an error.
//    ParseErrorHandlingController.handleParseError(error)
//    }
//}
