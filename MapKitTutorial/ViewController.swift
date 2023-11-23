//
//  ViewController.swift
//  MapKitTutorial
//
//  Created by Zohar Mosseri on 23/11/2023.
//


import UIKit
import MapKit
import CoreLocation


class ViewController : UIViewController {
    let locationManager = CLLocationManager()

    
    @IBOutlet weak var mapView: MKMapView!
    
    var resultSearchController:UISearchController? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        
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
        
        
    }
}

extension ViewController : CLLocationManagerDelegate, MKMapViewDelegate {

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
