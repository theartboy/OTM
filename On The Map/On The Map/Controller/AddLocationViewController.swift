//
//  AddLocationViewController.swift
//  On The Map
//
//  Created by John McCaffrey on 12/14/18.
//  Copyright © 2018 John McCaffrey. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class AddLocationViewController: UIViewController {
    @IBOutlet weak var locationTextfield: UITextField!
    @IBOutlet weak var linkTextfield: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    //TODO: after posting new location, call get student locations to update the studentmodel data
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        tabBarController?.tabBar.isHidden = true
        setFindLocation(false)
    }
//geocodeAddressString()
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postLocation" {
            let detailVC = segue.destination as! PostLocationViewController
            detailVC.locationString = ""
            detailVC.urlString = ""
        }
    }


    @IBAction func findLocationAction(_ sender: UIButton) {
        let geo = CLGeocoder()
        
        geo.geocodeAddressString(locationTextfield.text!) { (newLocation, error) in
            if error != nil {
                self.showFailure(title: "Cannot Find Loation", message: "Please submit your address in another format.")
            } else {
                print("new location: \(String(describing: newLocation))")
                //        performSegue(withIdentifier: "postLocation", sender: nil)
           }
        }
    }

    @IBAction func jumpy(_ sender: Any) {
        performSegue(withIdentifier: "postLocation", sender: nil)
    }
    
//    func handleLogoutResponse(success:Bool, error:Error?) {
//        if success {
//            //        https://stackoverflow.com/questions/30052587/how-can-i-go-back-to-the-initial-view-controller-in-swift
//            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
//        } else {
//            showFailure(title: "Unable to Find Location", message: error?.localizedDescription ?? "")
//        }
//
//    }
    func setFindLocation(_ findLocation: Bool) {
        if findLocation {
            activityIndicator.startAnimating()
            activityIndicator.alpha = 1
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.alpha = 0
        }
        locationTextfield.isEnabled = !findLocation
        linkTextfield.isEnabled = !findLocation
        findLocationButton.isEnabled = !findLocation
    }

    func showFailure(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                        self.setFindLocation(false)
        }))
        present(alertVC, animated: true)
//        show(alertVC, sender: nil)
    }
}

