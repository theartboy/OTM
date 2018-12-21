//
//  ViewController.swift
//  On The Map
//
//  Created by John McCaffrey on 12/13/18.
//  Copyright © 2018 John McCaffrey. All rights reserved.
//
//TODO: keyboard stuff
//TODO: constraints

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginViaWebsiteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setLoggingIn(false)

    }

   
    @IBAction func signupAction(_ sender: UIButton) {
        let app = UIApplication.shared
        let URLtoOpen = OTMClient.Endpoints.webSignup.url
        app.open(URLtoOpen)
    }
    
    //    https://auth.udacity.com/sign-up
    @IBAction func loginAction(_ sender: UIButton) {
        //update to textfield data
        //TODO: keyboard stuff
        OTMClient.login(username: credentials.username, password: credentials.password, completion: handleLoginResponse(success:error:))
        setLoggingIn(true)
    }
    
    func handleLoginResponse(success:Bool, error:Error?) {
        if success {
            OTMClient.getUserData(completion: handleUserDataResponse(success:error:))
            
        } else {
            showLoginFailure(title: "Login Failed", message: error?.localizedDescription ?? "")
        }
    }
    func handleUserDataResponse(success:Bool, error:Error?) {
        if success {
            OTMClient.getStudentLocations(completion: handleLocationDataResponse(success:error:))
            print("number of records \(StudentModel.students.count)")
            
        } else {
            showLoginFailure(title: "User Data Error", message: error?.localizedDescription ?? "")
        }
    }
    func handleLocationDataResponse(success:Bool, error:Error?) {
        if success {
            setLoggingIn(false)
            self.performSegue(withIdentifier: "completeLogin", sender: nil)
        } else {
            showLoginFailure(title: "Data Error", message: error?.localizedDescription ?? "")
        }
    }

    //MARK helper functions
    func setLoggingIn(_ loggingIn: Bool) {
        if loggingIn {
            activityIndicator.startAnimating()
            activityIndicator.alpha = 1
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.alpha = 0
        }
        emailTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
        loginViaWebsiteButton.isEnabled = !loggingIn
    }
    
    func showLoginFailure(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
            self.setLoggingIn(false)
        }))
        present(alertVC, animated: true)
//        show(alertVC, sender: nil)
    }

}

