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

class AddLocationViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var locationTextfield: UITextField!
    @IBOutlet weak var linkTextfield: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var locationString:String?
    var newPlacemark: CLPlacemark?
    var urlString: String?

    let inputTextFieldDelegate = InputTextFieldDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        tabBarController?.tabBar.isHidden = true
        setFindLocation(false)
        
        locationTextfield.delegate = inputTextFieldDelegate
        linkTextfield.delegate = inputTextFieldDelegate
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postLocation" {
            let detailVC = segue.destination as! PostLocationViewController
            detailVC.locationString = locationString
            detailVC.newPlacemark = newPlacemark
            detailVC.urlString = urlString
        }
    }

    
    @IBAction func findLocationAction(_ sender: UIButton) {
        setFindLocation(true)
        CLGeocoder().geocodeAddressString(locationTextfield.text!, completionHandler: {(newLocation, error)->Void in
                if error != nil {
                    self.showFailure(title: "Cannot Find Loation", message: error?.localizedDescription ?? "")
                } else {
                    self.setFindLocation(false)
                    self.newPlacemark = newLocation![0]
                    self.locationString = self.locationTextfield.text
                    self.urlString = self.linkTextfield.text
                    self.performSegue(withIdentifier: "postLocation", sender: nil)
                }
         })
    }

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
    }
}

