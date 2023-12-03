//
//  EventDetailsViewController.swift
//  MapKitTutorial
//
//  Created by Zohar Mosseri on 25/11/2023.
//

import Foundation
import UIKit
import FirebaseAuth
import MapKit

class EventDetailsViewController: UIViewController {

    var event: Event?

    
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
    
    private let titleLabel: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.layer.cornerRadius = 12
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.backgroundColor = .white
        textView.showsVerticalScrollIndicator = true
        textView.font = UIFont.boldSystemFont(ofSize: 18)
        return textView
    }()
    
    
    private let dateLabel : UILabel = {
        let field = UILabel()
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.backgroundColor = .white
        return field
    }()
    
    private let participantsLabel : UILabel = {
        let field = UILabel()
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.backgroundColor = .white
        return field
    }()
    
    private let mapDetail : MKMapView = {
        let field = MKMapView()
        return field
    }()
    
    
    private let addressTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.layer.cornerRadius = 12
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.backgroundColor = .white
        textView.showsVerticalScrollIndicator = true
        textView.font = UIFont.boldSystemFont(ofSize: 14)
        return textView
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.layer.cornerRadius = 12
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.backgroundColor = .white
        textView.showsVerticalScrollIndicator = true
        return textView
    }()
    
    
    private let joinButton : UIButton = {
        let button = UIButton()
        button.setTitle("JOIN", for: .normal)
        button.backgroundColor = .green
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight : .bold)
        button.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let navigateButton : UIButton = {
        let button = UIButton()
        button.setTitle("Navigate", for: .normal)
        if let printerImage = UIImage(systemName: "arrow.triangle.turn.up.right.circle")?.withRenderingMode(.alwaysTemplate) {
            let largerPrinterImage = printerImage.withConfiguration(UIImage.SymbolConfiguration(pointSize: 30))
            button.setImage(largerPrinterImage, for: .normal)
            button.imageView?.tintColor = .white // Set the color of the image
            button.semanticContentAttribute = .forceRightToLeft // To place the image on the right side
        }
        button.backgroundColor = .orange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight : .bold)
        button.addTarget(self, action: #selector(getDirections), for: .touchUpInside)
        return button
    }()
    
    private let findPrintShopsButton : UIButton = {
        let button = UIButton()
        button.setTitle("Find Print Shops!", for: .normal)
        if let printerImage = UIImage(systemName: "printer")?.withRenderingMode(.alwaysTemplate) {
            let largerPrinterImage = printerImage.withConfiguration(UIImage.SymbolConfiguration(pointSize: 30))
            button.setImage(largerPrinterImage, for: .normal)
            button.imageView?.tintColor = .white // Set the color of the image
            button.semanticContentAttribute = .forceRightToLeft // To place the image on the right side
        }
        button.backgroundColor = .blue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight : .bold)
        button.addTarget(self, action: #selector(findPrintShopsNearby), for: .touchUpInside)
        return button
    }()
    
    private let groupChatButton : UIButton = {
        let button = UIButton()
        button.setTitle("Group Chat", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight : .bold)
        //button.addTarget(self, action: #selector(groupChatButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadEventDetails()
        mapDetail.delegate = self
        
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(dateLabel)
        scrollView.addSubview(participantsLabel)
        scrollView.addSubview(mapDetail)
        scrollView.addSubview(addressTextView)
        scrollView.addSubview(descriptionTextView)
        scrollView.addSubview(joinButton)
        scrollView.addSubview(navigateButton)
        scrollView.addSubview(findPrintShopsButton)
        scrollView.addSubview(groupChatButton)

        // Customize the UI with event details
        if let event = event {
            titleLabel.text = event.title
            
            
            //location pin where the event is.
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: event.location, span: span)
            mapDetail.setRegion(region, animated: true)
            let annotation = MyAnnotation(coordinate: event.location)
            annotation.title = event.title
            annotation.EVENT_ID = event.id
            mapDetail.addAnnotation(annotation)
            addressTextView.text = "Address: \(event.address)"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            
            if let date = event.date {
                dateLabel.text = "Date: \(dateFormatter.string(from: date))"
            } else {
                dateLabel.text = "Date: N/A"
            }
            descriptionTextView.text = "Description: \(event.description ?? "N/A")"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadEventDetails()
        participantsLabel.text = "Number of Participants: " + String(event!.participants.count)
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        
        imageView.frame = CGRect(x: 30, y: 5, width: scrollView.width-60, height: 50)
        titleLabel.frame = CGRect(x: 30, y: imageView.bottom + 10, width: scrollView.width-60, height: 32)
        dateLabel.frame = CGRect(x: 30, y: titleLabel.bottom + 10, width: scrollView.width-60, height: 32)
        participantsLabel.frame = CGRect(x: 30, y: dateLabel.bottom + 5, width: scrollView.width-60, height: 32)
        mapDetail.frame = CGRect(x: 30, y: participantsLabel.bottom + 10, width: scrollView.width-60, height: 200)
        addressTextView.frame = CGRect(x: 30, y: mapDetail.bottom + 10, width: scrollView.width-60, height: 40)
        descriptionTextView.frame = CGRect(x: 30, y: addressTextView.bottom+10, width: scrollView.width-60, height: 100)
        
        joinButton.frame = CGRect(x: 30, y: descriptionTextView.bottom+10, width: (scrollView.width-60)/2, height: 32)
        navigateButton.frame = CGRect(x: joinButton.right + 10, y: descriptionTextView.bottom+10, width: (scrollView.width-60)/2, height: 32)
        findPrintShopsButton.frame = CGRect(x: 30, y: navigateButton.bottom+10, width: (scrollView.width-60)/2, height: 32)
        groupChatButton.frame = CGRect(x: findPrintShopsButton.right + 10, y: navigateButton.bottom+10, width: (scrollView.width-60)/2, height: 32)
    }
    
    //Getting directions to the selected pin
    @objc func getDirections(){
        if let event = event {
            let pinPlaceMark = MKPlacemark(coordinate: event.location)
            let mapItem = MKMapItem(placemark: pinPlaceMark)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    //Getting directions to the selected pin
    @objc func findPrintShopsNearby(){
        if let event = event {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = "Print Shop"
            let region = MKCoordinateRegion(center: event.location, latitudinalMeters: 5000, longitudinalMeters: 5000)
            request.region = region
            
            let search = MKLocalSearch(request: request)
            search.start { (response, error) in
                guard let response = response, error == nil else {
                    // Handle the error
                    return
                }
                for item in response.mapItems {
                    let annotation = PrintShopAnnotation(coordinate: item.placemark.coordinate)
                    annotation.title = item.name
                    //todo change to mapView with delegates and stuff :)
                    self.mapDetail.addAnnotation(annotation)
                }
            }
        }
    }
    
    /*
    //TODO big check if it actually changes
    func setupEvent(chosenEvent: Event?) {
        //print(chosenEvent?.id)
        event = EventManager.shared.getEvent(withId: chosenEvent!.id)
    }
    */
    
    func loadEventDetails() {
        // Ensure event is not nil before using it
        guard let event = event else {
            // Handle the case where event is nil
            return
        }
    }
    
    @IBAction func close(){
        return dismiss(animated: true)
    }
    
    
    
//    let currentUser = User(firstName: "Zohar", lastName: "Mosseri", email: "zizu@gmail.com", events: [])

    
    // Handle the "Join" button tap
    @objc func joinButtonTapped() {
        
        
        if joinButton.backgroundColor == .green { //user has not joined before
            //getting current user from database
            guard var fireBaseUser = FirebaseAuth.Auth.auth().currentUser else{
                print("cant retrieve user from database in creating new event")
                return
            }
            let dataShared = DatabaseManager.shared
            
            //todo check if you want to run users like that : //let user = UserManager.shared.users[fireBaseUser.uid]
            print(DatabaseManager.makeSafeEmail(with: fireBaseUser.email!))
            
            dataShared.getUserData(with: DatabaseManager.makeSafeEmail(with: fireBaseUser.email!)) { (user) in
                if var user = user {
                    dataShared.addUserToEvent(user: &fireBaseUser, event: &(self.event)!, completion: { success in
                        if success {
                            print("Event updated successfully.")
                        } else {
                            print("Failed to update event.")
                        }
                    })
                } else {
                    print("User not found")
                }
            }
            joinButton.backgroundColor = .red
            joinButton.setTitle("JOINED", for: .normal)
        }
    }
}

extension EventDetailsViewController : MKMapViewDelegate {
    
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
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        
        if let eventAnnotation = annotation as? MyAnnotation {
            pinView?.markerTintColor = UIColor.red
        } else if let printShopAnnotation = annotation as? PrintShopAnnotation {
            pinView?.image = UIImage(named: "car")
            pinView?.frame = CGRect(x: 0, y: 0, width: 20, height: 20) // Adjust the size as needed
            
            pinView?.markerTintColor = UIColor.blue
        }
        
        let carButton = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
        carButton.setBackgroundImage(UIImage(named: "car"), for: [])
        carButton.addTarget(self, action: #selector(getDirections), for: .touchUpInside) //todo big check here
        pinView?.rightCalloutAccessoryView = carButton
        
        return pinView
    }
}
