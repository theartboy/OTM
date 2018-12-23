//
//  PinViewController.swift
//  On The Map
//
//  Created by John McCaffrey on 12/14/18.
//  Copyright © 2018 John McCaffrey. All rights reserved.
//

import UIKit

class PinViewController: UIViewController {

 
    @IBOutlet weak var tableView: UITableView!
    
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
     }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false

        tableView.reloadData()
    }
    

    @IBAction func logoutAction(_ sender: UIBarButtonItem) {
        OTMClient.logout(completion: handleLogoutResponse(success:error:))
    }
    
    @IBAction func reloadAction(_ sender: UIBarButtonItem) {
        tableView.reloadData()
    }
    
    @IBAction func addLocationAction(_ sender: UIBarButtonItem) {
        OTMClient.getStudentLocation(completion: handleCheckForExistingLocationRecord(success:error:))
   }
    
    func handleCheckForExistingLocationRecord(success: Bool, error: Error?) {
        if success {
            showWarning(title: "User Pin Exists", message: "Do you want to update your user pin to a new location?")
            
        } else {
            performSegue(withIdentifier: "addLocation", sender: nil)
            
        }
    }
    
    func handleLogoutResponse(success:Bool, error:Error?) {
        if success {
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        } else {
            showFailure(title: "Logout Failed", message: error?.localizedDescription ?? "")
        }
    }
    
    func showFailure(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true)
    }
    
    func showWarning(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OVERWRITE", style: .default, handler: {action in
            self.performSegue(withIdentifier: "addLocation", sender: nil)
        }))
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertVC, animated: true)
    }
}

extension PinViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("student count \(StudentModel.students.count)")
        return StudentModel.students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PinTableViewCell")!
        
        let student = StudentModel.students[indexPath.row]
        let fullName = "\(student.firstName) \(student.lastName)"
        
        cell.textLabel?.text = fullName
        cell.detailTextLabel?.text = student.mediaURL        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        let app = UIApplication.shared
        let URLtoOpen = StudentModel.students[selectedIndex].mediaURL
        if URLtoOpen != "" {
            app.open(URL(string: URLtoOpen)!)
        }
        

        tableView.deselectRow(at: indexPath, animated: true)
    }


}
