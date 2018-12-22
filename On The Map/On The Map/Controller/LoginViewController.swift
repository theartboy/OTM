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

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginViaWebsiteButton: UIButton!
    
    let inputTextFieldDelegate = InputTextFieldDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setLoggingIn(false)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
 
        setUpTextFields(tf: emailTextField)
        setUpTextFields(tf: passwordTextField)
   }
    
    func setUpTextFields(tf: UITextField){
        tf.delegate = inputTextFieldDelegate
        tf.text = ""
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
        if emailTextField.text == "" || passwordTextField.text == "" {
            showLoginFailure(title: "Login Failed", message: "Please provide a username and password.")
        } else {
            OTMClient.login(username: emailTextField.text ?? "", password: passwordTextField.text ?? "", completion: handleLoginResponse(success:error:))
            setLoggingIn(true)

        }
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
    
    //MARK: Keyboard items
    @objc func keyboardWillShow(_ notification:Notification){
        //verify it the bottom textfield before shifting keyboard
        if emailTextField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
         if notification.name == UIResponder.keyboardWillHideNotification {
            view.frame.origin.y = 0
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification){
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification)-> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications(){
//        NotificationCenter.default.addObserver(self, selector: keyboardWillShow(Notification), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)    }
    
    func unsubscribeFromKeyboardNotifications(){
//        NotificationCenter.default.removeObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)    }
    }

}

