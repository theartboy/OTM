//
//  MapViewController.swift
//  On The Map
//
//  Created by John McCaffrey on 12/14/18.
//  Copyright © 2018 John McCaffrey. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var addLocationButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    var initialLocation:CLLocation = CLLocation(latitude: 44.899221, longitude: -92.875861)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self//need this or the delegate functions will not run
        
//        let london = MKPointAnnotation()
//        london.title = "London"
//        london.coordinate = CLLocationCoordinate2D(latitude: 44.899221, longitude: -92.875861)
//        london.subtitle = "https://www.theartboy.com/paint"
//        mapView.addAnnotation(london)
        
        
        
        refreshAnnotations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        tabBarController?.tabBar.isHidden = false
        print("student pin list: \(StudentModel.students.count)")
        print("pins\(mapView.annotations.count)")
        mapView.reloadInputViews()
    }
    
    func refreshAnnotations(){
        for annon in mapView.annotations {
            mapView.removeAnnotation(annon)
        }
        for student in StudentModel.students {
            let pin = MKPointAnnotation()
            pin.title = student.mapString
            pin.coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
            pin.subtitle = student.mediaURL
            self.mapView.addAnnotation(pin)
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    

    @IBAction func logoutAction(_ sender: Any) {
        OTMClient.logout(completion: handleLogoutResponse(success:error:))
    }
    
    @IBAction func refreshButtonAction(_ sender: Any) {
        refreshAnnotations()
    }
    
    @IBAction func addLocationButtonAction(_ sender: Any) {
//        performSegue(withIdentifier: "addLocation", sender: nil)
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
            //        https://stackoverflow.com/questions/30052587/how-can-i-go-back-to-the-initial-view-controller-in-swift
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

extension MapViewController: MKMapViewDelegate {
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
