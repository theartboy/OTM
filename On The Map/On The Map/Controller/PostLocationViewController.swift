//
//  PostLocationViewController.swift
//  On The Map
//
//  Created by John McCaffrey on 12/14/18.
//  Copyright © 2018 John McCaffrey. All rights reserved.
//
//TODO: otm POST
//TODO: button response function
//TODO: remember to async
//TODO: error alertVC

import UIKit
import MapKit
import CoreLocation

class PostLocationViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var locationString: String!
    var urlString: String!
    var newPlacemark: CLPlacemark!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        // Do any additional setup after loading the view.
        let newPin = MKPointAnnotation()
        newPin.title = locationString
        newPin.coordinate = (newPlacemark.location?.coordinate)!//CLLocationCoordinate2D(latitude: (newPlacemark.location?.coordinate.latitude)!, longitude: (newPlacemark.location?.coordinate.longitude)!)
        newPin.subtitle = urlString
        mapView.addAnnotation(newPin)
        setAddLocation(false)
   }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        tabBarController?.tabBar.isHidden = true
        centerMapOnLocation(location: newPlacemark.location!)
//        mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2DMake ((newPlacemark.location?.coordinate.latitude)!, (newPlacemark.location?.coordinate.longitude)!), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)), animated: true)
    }
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 10000
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    @IBAction func finishButtonAction(_ sender: UIButton) {
        setAddLocation(true)
        let lat = CLLocationDegrees(Double((newPlacemark.location?.coordinate.latitude)!))
        let lon = CLLocationDegrees(Double((newPlacemark.location?.coordinate.longitude)!))
        if OTMClient.Auth.objId == "" {
            OTMClient.postNewLocation(locationName: locationString, mediaURL: urlString, lat: lat, lon: lon, completion: handleFinishAction(success:error:))
        } else {
            OTMClient.putNewLocation(locationName: locationString, mediaURL: urlString, lat: lat, lon: lon, completion: handleFinishAction(success:error:))
        }
     }
//    @IBAction func popVC(_ sender: Any) {
////        OTMClient.Auth.sessionId = ""
//        navigationController?.popToRootViewController(animated: true)
////        https://stackoverflow.com/questions/30052587/how-can-i-go-back-to-the-initial-view-controller-in-swift
////        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
//   }
    func handleFinishAction(success: Bool, error: Error?){
        if success {
            OTMClient.getStudentLocations(completion: handleLocationDataResponse(success:error:))
        } else {
            showFailure(title: "Add Location Failed", message: error?.localizedDescription ?? "")
        }
    }
 
    func handleLocationDataResponse(success:Bool, error:Error?) {
        if success {
            setAddLocation(false)
            navigationController?.popToRootViewController(animated: true)
        } else {
            showFailure(title: "Location Data Failed", message: error?.localizedDescription ?? "")
        }
    }

    //MARK helper functions
    func setAddLocation(_ Adding: Bool) {
        if Adding {
            activityIndicator.startAnimating()
            activityIndicator.alpha = 1
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.alpha = 0
        }
        finishButton.isEnabled = !Adding
    }
    
    func showFailure(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true)
    }

}

extension PostLocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView//casting as type allows for pin tinting
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier) as MKPinAnnotationView
            annotationView?.pinTintColor = UIColor.blue
            annotationView?.canShowCallout = true
            annotationView?.tintColor = .purple//callout info button color
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let URLtoOpen = view.annotation?.subtitle! {
                app.open(URL(string: URLtoOpen)!)
            }
        }
    }
    
}
