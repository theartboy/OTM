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
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        tabBarController?.tabBar.isHidden = true
        centerMapOnLocation(location: newPlacemark.location!)
//        mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2DMake ((newPlacemark.location?.coordinate.latitude)!, (newPlacemark.location?.coordinate.longitude)!), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)), animated: true)
    }
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 100
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    @IBAction func finishButtonAction(_ sender: UIButton) {
        //call OTM post function then call success function handler
        navigationController?.popToRootViewController(animated: true)
     }
    @IBAction func popVC(_ sender: Any) {
//        OTMClient.Auth.sessionId = ""
        navigationController?.popToRootViewController(animated: true)
//        https://stackoverflow.com/questions/30052587/how-can-i-go-back-to-the-initial-view-controller-in-swift
//        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
   }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
