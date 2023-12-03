//
//  ProfileViewController.swift
//  MapKitTutorial
//
//  Created by Zohar Mosseri on 30/11/2023.
//

import Foundation
import UIKit
import MapKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    //@IBOutlet var tableView : UITableView?
    
    var userEvents = [Event]()
    let eventsTableViewController = UITableViewController(style: .plain)

    
    private let scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = imageView.width/2.0
        return imageView
    }()
    
    private let nameLabel : UILabel = {
        let field = UILabel()
        field.layer.cornerRadius = 12
        field.text = "Name: "
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.backgroundColor = .white
        return field
    }()

    private let emailLabel : UILabel = {
        let field = UILabel()
        field.layer.cornerRadius = 12
        field.text = "Email: "
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.backgroundColor = .white
        return field
    }()

    private let myEventsButton : UIButton = {
        let button = UIButton()
        button.setTitle("My Events", for: .normal)
        button.backgroundColor = .orange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight : .bold)
        return button
    }()
    
    private let logoutButton : UIButton = {
        let button = UIButton()
        button.setTitle("Log Out", for: .normal)
        button.backgroundColor = .red
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight : .bold)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventsTableViewController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // Create a table view controller
        eventsTableViewController.tableView.delegate = self
        eventsTableViewController.tableView.dataSource = self
        
        myEventsButton.addTarget(self, action: #selector(showMyEvents), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)

        
        imageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(didTapChangeProfilePic))
        imageView.addGestureRecognizer(gesture)
        
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(nameLabel)
        scrollView.addSubview(emailLabel)
        scrollView.addSubview(myEventsButton)
        scrollView.addSubview(logoutButton)
         
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String,
              let name = UserDefaults.standard.value(forKey: "name") as? String
        else{
            print("cant retrieve user details from UserDefaults in profile")
            return
        }
        
        
        
        
        let safeEmail = DatabaseManager.makeSafeEmail(with: email)
        
        //showMyEvents(safeEmail: safeEmail)
        
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/" + fileName

        
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let url):
                
                strongSelf.downloadImageView(imageX: strongSelf.imageView, url: url)
                strongSelf.imageView.sd_setImage(with: url, completed: nil)
                print("sd_setImage succeded")
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
        })
        
        nameLabel.text = "Name: " + name
        emailLabel.text = "Email: " + email
    }
    
    func downloadImageView(imageX : UIImageView, url : URL){
        
        URLSession.shared.dataTask(with: url, completionHandler: {data, _, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.imageView.image = image
            }
        }).resume()
    }
    
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        

        
        imageView.frame = CGRect(x: (scrollView.width-size)/2, y: 20, width: size, height: size)
        nameLabel.frame = CGRect(x: 30, y: imageView.bottom + 15, width: scrollView.width-60, height: 32)
        emailLabel.frame = CGRect(x: 30, y: nameLabel.bottom + 30, width: scrollView.width-60, height: 32)
        myEventsButton.frame = CGRect(x: 30, y: emailLabel.bottom + 30, width: scrollView.width-60, height: 32)
        logoutButton.frame = CGRect(x: 30, y: myEventsButton.bottom + 30, width: scrollView.width-60, height: 32)
        //tableView.frame = CGRect(x: 30, y: eventsLabel.bottom + 30, width: scrollView.width-60, height: 32)
    }
    
    @objc private func logoutButtonTapped(){
        
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            
            guard let strongSelf = self else {
                return
            }
            UserDefaults.standard.setValue(nil, forKey: "email")
            UserDefaults.standard.setValue(nil, forKey: "User ID")
            UserDefaults.standard.setValue(nil, forKey: "name")
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
            }
            catch {
                print("Failed to log out")
            }
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        self.present(actionSheet, animated: true)
    }
    
    ///if user clicks on his events so he can see all his events
    @objc private func showMyEvents(){
        var userEventsIDs = [String]()

        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            print("Can't retrieve user details from UserDefaults in profile")
            return
        }
        let safeEmail = DatabaseManager.makeSafeEmail(with: email)
        DatabaseManager.shared.getUserData(with: safeEmail) { (user) in
            if let user = user {
                userEventsIDs = user.events
            } else {
                print("User not found in showMyEvents")
            }
        }

        DatabaseManager.shared.getAllEvents(completion: { [weak self] (events) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.userEvents = []
            print("before")
            print(strongSelf.userEvents)
            
            for eventID in userEventsIDs {
                if eventID != "dummy"{
                    if let unwrappedEvent = events[eventID] {
                        strongSelf.userEvents.append(unwrappedEvent)
                    }
                }
            }
            print("after")
            print(strongSelf.userEvents)
            
            if strongSelf.eventsTableViewController.tableView != nil {
                DispatchQueue.main.async {
                    strongSelf.eventsTableViewController.tableView?.reloadData()
                }
            } else {
                print("strongSelf.tableView is nil")
            }
            
            
            
            //print(strongSelf.userEvents)
            
            /*
            for userEvent in strongSelf.userEvents{
                print("not dummy and in userEvents")
                //print(strongSelf.userEvents.count)
                print(userEvent)
            }
             */
             
        })

        
        // Create and configure the alert controller, depends if no events or there are some events to choose from
        let alertController = self.userEvents.isEmpty ? UIAlertController(title: "No Events", message: "Create a new event!", preferredStyle: .actionSheet) : UIAlertController(title: "My Events", message: "Choose an event!", preferredStyle: .actionSheet)
        
        // Embed the table view controller in the alert controller
        alertController.setValue(self.eventsTableViewController, forKey: "contentViewController")
        
        // Add a cancel action to dismiss the alert
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the alert controller
        present(alertController, animated: true, completion: nil)
        
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfEvents = userEvents.count
        return numberOfEvents == 0 ? 1 : numberOfEvents //1 cell for showing "Create Event" or the number of events
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.textColor = .blue
        cell.textLabel?.textAlignment = .center
        
        if userEvents.isEmpty {
            cell.textLabel?.text = "Create Event"
        } else {
            // Display cells with event details
            let event = userEvents[indexPath.row]
            cell.textLabel?.text = event.title
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !userEvents.isEmpty {
            let selectedEvent = userEvents[indexPath.row]
            // Dismiss any existing view controller before presenting EventDetailsViewController
            if let presentedViewController = presentedViewController {
                presentedViewController.dismiss(animated: true) {
                    self.presentEventDetails(for: selectedEvent)
                }
            } else {
                // No view controller is currently being presented, proceed to present EventDetailsViewController
                presentEventDetails(for: selectedEvent)
            }
        }
        else{ //isEmpty
            // Dismiss any existing view controller before presenting EventDetailsViewController
            if let presentedViewController = presentedViewController {
                presentedViewController.dismiss(animated: true) {
                    self.presentCreateEvent()
                }
            } else {
                // No view controller is currently being presented, proceed to present EventDetailsViewController
                presentCreateEvent()
            }
        }
    }
    
    private func presentEventDetails(for event: Event) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let eventDetailsVC = storyboard.instantiateViewController(withIdentifier: "EventDetailsViewController") as? EventDetailsViewController {
            eventDetailsVC.event = event
            present(eventDetailsVC, animated: true, completion: nil)
        }
    }
    
    private func presentCreateEvent() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let createEventVC = storyboard.instantiateViewController(withIdentifier: "CreateEventViewController") as? CreateEventViewController {
            present(createEventVC, animated: true, completion: nil)
        }
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc private func didTapChangeProfilePic() {
        
        /*
        guard let strongSelf = self else {
            return
        }*/
        
        presentPhotoActionSheet()
        
        // upload image
        guard let image = self.imageView.image,
            let data = image.pngData() else {
                return
        }
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return
        }
        
        let safeEmail = DatabaseManager.makeSafeEmail(with: email)
        let fileName = safeEmail + "_profile_picture.png"
        //let fileName = user.profilePicFileName
        
        print(fileName)
        
        StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: { result in
            switch result {
            case .success(let downloadUrl):
                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                print("uploadProfilePicture succeded, URL : " + downloadUrl)
            case .failure(let error):
                print("Storage manager error: \(error)")
            }
        })
    }

    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select a picture?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: { [weak self] _ in

                                                self?.presentCamera()

        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentPhotoPicker()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Remove Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.deletePhoto()
        }))

        present(actionSheet, animated: true)
    }

    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }

    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func deletePhoto() {
        self.imageView.image = UIImage(systemName: "person.circle")
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.imageView.image = selectedImage
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
