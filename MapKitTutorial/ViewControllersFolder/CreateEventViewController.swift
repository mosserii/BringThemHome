//
//  CreateEventViewController.swift
//  MapKitTutorial
//
//  Created by Zohar Mosseri on 26/11/2023.
//
import Foundation
import UIKit
import MapKit
import CoreLocation
import FirebaseAuth




class CreateEventViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    var selectedPin:MKPlacemark? = nil
    //@IBOutlet weak var mapView: MKMapView!
    var resultSearchController:UISearchController? = nil
    
    var searchBar: UISearchBar?
    var chosenCoordinates: CLLocationCoordinate2D?


    private let scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "BringThemHomeNow")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Event Title"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let datePicker : UIDatePicker = {
        let field = UIDatePicker()
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.backgroundColor = .white
        field.minimumDate = .now
        return field
    }()
    
    
    private let mapView : MKMapView = {
        let field = MKMapView()
        //field.layer.borderColor = UIColor.lightGray.cgColor
        //field.backgroundColor = .white
        return field
    }()
    
    
    private let addressField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let descField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Describe the event..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    
    private let sumbitButton : UIButton = {
        let button = UIButton()
        button.setTitle("Add event!", for: .normal)
        button.backgroundColor = .blue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight : .bold)
        return button
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        
        //Table of locations (with StoryBoard ID of LocationSearchTable)
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        
        // the Search Bar itself, configured and embeded within the navigation bar
        //let searchBar = resultSearchController!.searchBar
        searchBar = resultSearchController?.searchBar
        searchBar?.sizeToFit()
        searchBar?.placeholder = "Enter Address..."
        //navigationItem.titleView = resultSearchController?.searchBar
        
        
        //gives a nicer search experience
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        //resultSearchController?.obscuresBackgroundDuringPresentation = true //todo check if neceassery
        definesPresentationContext = true
        
        
        sumbitButton.addTarget(self, action: #selector(sumbitButtonTapped), for: .touchUpInside)

        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(searchBar!)
        scrollView.addSubview(titleField)
        scrollView.addSubview(datePicker)
        scrollView.addSubview(mapView)
        scrollView.addSubview(addressField)
        scrollView.addSubview(descField)
        scrollView.addSubview(sumbitButton)
        
        
        //connecting the map with locationSearchTable file TODO big check if it doesnt delete all the existing annotations of events!
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        
        imageView.frame = CGRect(x: 30, y: -30, width: scrollView.width-60, height: 50)
        searchBar?.frame = CGRect(x: 30, y: imageView.bottom + 10, width: scrollView.width-60, height: 32)
        titleField.frame = CGRect(x: 30, y: (searchBar?.bottom ?? 60) + 30, width: scrollView.width-60, height: 32)
        datePicker.frame = CGRect(x: 30, y: titleField.bottom + 5, width: scrollView.width-60, height: 32)
        mapView.frame = CGRect(x: 30, y: datePicker.bottom + 10, width: scrollView.width-60, height: 200)
        addressField.frame = CGRect(x: 30, y: mapView.bottom + 10, width: scrollView.width-60, height: 32)
        descField.frame = CGRect(x: 30, y: addressField.bottom+10, width: scrollView.width-60, height: 100)
        sumbitButton.frame = CGRect(x: 30, y: descField.bottom+10, width: scrollView.width-60, height: 32)
    }
    
    
    @objc private func sumbitButtonTapped(){
        
        titleField.resignFirstResponder()
        addressField.resignFirstResponder()
        descField.resignFirstResponder()
        
        
        guard let eventTitle = titleField.text, let eventAddress = addressField.text,
              !eventTitle.isEmpty, !eventAddress.isEmpty else {
            alertEventCreationError(message: "Please enter all information to create an event")
                return
        }
        
        //getting current user from database
        guard var fireBaseUser = FirebaseAuth.Auth.auth().currentUser else{
            print("cant retrieve user from database in creating new event")
            return
        }
        
        let currentUserID = fireBaseUser.uid
        
        var newEvent = Event(title: eventTitle, location: chosenCoordinates!, address: eventAddress, date: datePicker.date,description: descField.text, participants: [])
        
        DatabaseManager.shared.insertEvent(with: newEvent) { success in
            if success {
                print("Event inserted successfully")
            } else {
                print("Failed to insert event")
            }
        }
        
        DatabaseManager.shared.addUserToEvent(user: &fireBaseUser, event: &newEvent, completion: { success in
            if success {
                print("addUserToEvent successfully.")
            } else {
                print("Failed to addUserToEvent.")
            }
        })
        
        
        EventManager.shared.events[newEvent.id] = newEvent
        
        
        EventManager.shared.eventAddedDelegate?.didAddNewEvent(newEvent)
        navigationController?.popViewController(animated: true)
        

        
        let alertController = UIAlertController(title: "Event Created", message: "Your new event has been created successfully.", preferredStyle: .alert)
        present(alertController, animated: true, completion: nil)
           // Dismiss the alert after a delay (e.g., 2 seconds)
           DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
               alertController.dismiss(animated: true, completion: nil)
               self.navigateToEventDetails(with: newEvent.id)
           }
    }
    
    func alertEventCreationError(message:String){
        let alert = UIAlertController(title: "whoops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    
    
    //move to event details page!!!!
    //todo its a duplicate func like in ViewController!!!!!!! change it
    func navigateToEventDetails(with eventId: String) {

        // Instantiate the EventDetailsViewController using its storyboard ID
        if let eventDetailsVC = storyboard!.instantiateViewController(withIdentifier: "EventDetailsViewController") as? EventDetailsViewController {
            
            let specificEvent = EventManager.shared.getEvent(withId: eventId)
            //eventDetailsVC.setupEvent(chosenEvent: specificEvent)
            eventDetailsVC.event = specificEvent
            present(eventDetailsVC, animated: true, completion: nil)
        }
    }
     
}

extension CreateEventViewController : CLLocationManagerDelegate {

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

extension CreateEventViewController: HandleMapSearchDelegate {
    
    //todo : Use this function for mapSearch but also for keeping events (new event adds new annotation)
    //todo change name
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MyAnnotation(coordinate: placemark.coordinate)
        annotation.title = "New Event Here"
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        
        //showing it on the map
        mapView.setRegion(region, animated: true)
        
    }
}

extension CreateEventViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        //TODOOOOOO annotation.EVENT_ID
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.markerTintColor = UIColor.blue
        pinView?.animatesWhenAdded = true
        pinView?.isDraggable = true
        pinView?.canShowCallout = true
        
        getAddressForCoordinates(annotation.coordinate)
        
        return pinView
    }
    
    // MKMapViewDelegate method
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        if newState == .ending {
            // Get the new coordinates of the draggable annotation
            if let newCoordinate = view.annotation?.coordinate {
                getAddressForCoordinates(newCoordinate)
            }
        }
    }

    // Function to get address for coordinates using reverse geocoding
    func getAddressForCoordinates(_ coordinates: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
                // Access the address components from the placemark
                if let address = placemark.compactAddress {
                    self.searchBar?.text = address
                    print("New address: \(address)")
                    self.addressField.text = address
                    self.chosenCoordinates = coordinates
                }
            }
        }
    }
}


extension CLPlacemark {
    var compactAddress: String? {
        if let name = name {
            var address = name
            if let city = locality {
                address += ", \(city)"
            }
            if let state = administrativeArea {
                address += ", \(state)"
            }
            if let country = country {
                address += ", \(country)"
            }
            return address
        }
        return nil
    }
}


    
