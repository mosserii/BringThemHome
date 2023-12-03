//
//  MapViewController.swift
//  MapKitTutorial
//
//  Created by Zohar Mosseri on 27/11/2023.
//

/*
import Foundation
import UIKit
import MapKit
import CoreLocation
import FirebaseAuth



protocol HandleMapSearchDelegate {
    func dropPinZoomIn(placemark:MKPlacemark)
}


class MapViewController : UIViewController {
    let locationManager = CLLocationManager()
    var selectedPin:MKPlacemark? = nil
    @IBOutlet weak var mapView: MKMapView!
    var resultSearchController:UISearchController? = nil
    
    var createEventController:CreateEventViewController? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        
        
        // Load events and add annotations
        loadAndDisplayEvents()
        
        
        //Table of locations (with StoryBoard ID of LocationSearchTable)
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        
        // the Search Bar itself, configured and embeded within the navigation bar
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for locations"
        navigationItem.titleView = resultSearchController?.searchBar
        
        
        //gives a nicer search experience
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        //resultSearchController?.obscuresBackgroundDuringPresentation = true //todo check if neceassery
        definesPresentationContext = true
        
        //connecting the map with locationSearchTable file
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
        if let nav = segue.destination as? UINavigationController,
           let classBVC = nav.topViewController as? CreateEventViewController {
        classBVC.eventAddedDelegate = self
        }

    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //todo change to let
        //let isLoggedIn = UserDefaults.standard.bool(forKey: "logged_in")
        
        validateAuth()
        //todo delete
        //isLoggedIn = true
        
        
    }
    
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let LVC = LoginViewController()
            let nav = UINavigationController(rootViewController: LVC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
    
    func loadAndDisplayEvents(){
        
        /*todo delete, these are just examples*/
        EventManager.shared.createEvent(eventTitle: "hola", eventLocation: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4294), addr: "42 Moryia st.", date: Date(), desc: "Let's all meet in the 10eme arr.")
       
        EventManager.shared.createEvent(eventTitle: "holy", eventLocation: CLLocationCoordinate2D(latitude: 37.7749, longitude: -121.4294), addr: "40 Moryia st.", date: Date(), desc: "Let's all meet in the 1 arr.")

        
        let allEvents = EventManager.shared.getAllEvents()
        
        for event in allEvents {
            
            addNewAnnotation(event)
            
            /* same as in the function addNewAnnotation
            let annotation = MyAnnotation(coordinate: event.location)
            annotation.title = event.title
            annotation.EVENT_ID = event.id
            mapView.addAnnotation(annotation)
            */
            /*
            let annotation = MKPointAnnotation()
            annotation.coordinate = event.location
            //annotation.title = event.title
            annotation.title = event.id
            mapView.addAnnotation(annotation)
             */
            
        }
    }
    
    
    //Getting directions to the selected pin
    @objc func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin) //Converting the cached selectedPin to a MKMapItem
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    @objc func navigateToEventDetails(with eventId: String) {
        // Assuming your storyboard is named "Main"
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // Instantiate the EventDetailsViewController using its storyboard ID
        if let eventDetailsVC = storyboard!.instantiateViewController(withIdentifier: "EventDetailsViewController") as? EventDetailsViewController {
            
            let specificEvent = EventManager.shared.getEvent(withId: eventId)
            //eventDetailsVC.setupEvent(chosenEvent: specificEvent)
            eventDetailsVC.event = specificEvent
            present(eventDetailsVC, animated: true, completion: nil)
        }
    }
    
    func addNewAnnotation(_ event:Event){
        let annotation = MyAnnotation(coordinate: event.location)
        annotation.title = event.title
        annotation.EVENT_ID = event.id
        mapView.addAnnotation(annotation)
    }
    
}

extension MapViewController : CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print("error:: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    // only interested in the first location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }

}


extension MapViewController: HandleMapSearchDelegate {
    
    //todo : Use this function for mapSearch but also for keeping events (new event adds new annotation)
    //todo change name
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        
        //showing it on the map
        mapView.setRegion(region, animated: true)
        
    }
}

extension MapViewController : MKMapViewDelegate {
 
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        
         if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        //TODOOOOOO annotation.EVENT_ID
            
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        //pinView?.image = UIImage(named: "car")
        pinView?.markerTintColor = UIColor.red
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(type: .infoLight)
        button.frame = CGRect(origin: CGPoint.zero, size: smallSquare)
        pinView?.rightCalloutAccessoryView = button
            
        return pinView
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            // Access the event ID from the annotation and perform navigation
            if let eventAnnotation = view.annotation as? MyAnnotation {
                let eventId = eventAnnotation.EVENT_ID!
                navigateToEventDetails(with: eventId)
            }
        }
    }
}

extension MapViewController : EventAddedDelegate {
    
    
    func didAddNewEvent(_ event: Event) {
        print(event.title)
        addNewAnnotation(event)
    }
    
}

*/
