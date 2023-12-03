//
//  DatabaseManager.swift
//  MapKitTutorial
//
//  Created by Zohar Mosseri on 26/11/2023.
//

import Foundation
import FirebaseDatabase
import CoreLocation
import FirebaseAuth

final class DatabaseManager{
    
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
 
    
    /// Returns dictionary node at child path
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
    
    
    
    static func makeSafeEmail(with email: String) -> String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "_")
        return safeEmail
    }
    
}

//for users
extension DatabaseManager{
    
    public func userExists(with email: String, completion: @escaping((Bool)->Void)){
        let safeEmail = DatabaseManager.makeSafeEmail(with: email)
        database.child("users").child(safeEmail).observeSingleEvent(of: .value, with: {snapshot in
            guard snapshot.value as? String != nil else{
                completion(false) //email does not exist
                return
            }
            completion(true)
        })
    }
     
    ///Inserts a new event to database
    public func insertUser(with user: User, completion: @escaping (Bool) -> Void){
        
        let safeEmail = DatabaseManager.makeSafeEmail(with: user.email)
        
        let userValues: [String: Any] = [
            "User ID": user.id,
            "first_name": user.firstName,
            "last_name": user.lastName,
            "events": ["dummy"]
        ]
        
        database.child("users").child(safeEmail).setValue(userValues) { error, _ in
            if let error = error {
                print("Failed to write to database in insertUser: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
        
    
    /// Gets all users from the database
    func getAllUsers(completion: @escaping ([String: User]) -> Void) {
        //todo something with email!!!!!
        
        database.child("users").observeSingleEvent(of: .value) { (snapshot) in
            guard let userSnapshots = snapshot.children.allObjects as? [DataSnapshot] else {
                completion([:])
                return
            }
            var users: [String: User] = [:]
            if let usersData = snapshot.value as? [String: [String: Any]] {
                for (safeEmail, userData) in usersData {
                    guard let userId = userData["User ID"] as? String,
                          let firstName = userData["first name"] as? String,
                          let lastName = userData["last name"] as? String,
                          let eventsData = userData["events"] as? [String]
                    else{
                        continue
                    }
                    
                    let user = User(id: userId, firstName: firstName, lastName: lastName, email:safeEmail, events: eventsData)
                    users[user.id] = user
                }
            }
            completion(users)
        }
    }
    
    
    public func getUserData(with email: String, completion: @escaping (User?) -> Void) {
        let safeEmail = DatabaseManager.makeSafeEmail(with: email)
        
        database.child("users").child(safeEmail).observeSingleEvent(of: .value) { (snapshot, error) in
            
            guard let userData = snapshot.value as? [String: Any],
                  let userId = userData["User ID"] as? String,
                  let firstName = userData["first_name"] as? String,
                  let lastName = userData["last_name"] as? String,
                  let eventsData = userData["events"] as? [String]
            else {
                print("failed to get user data")
                completion(nil)
                return
            }
            
            let user = User(id: userId, firstName: firstName, lastName: lastName, email: email, events: eventsData)
            //let user = User(id : userId, firstName: firstName, lastName: lastName, email: email, events: [])
            completion(user)
        }
    }
    
    
    
    
    
    
    //todo check if you want fireBaseUser instead of a User
    //TODO Addition of user to event, works both for creation of event and a user clicking on JOIN
    public func addUserToEvent(user:inout FirebaseAuth.User, event:inout Event, completion: @escaping (Bool) -> Void){
        
        
        let eventRef = database.child("events").child(event.id)
        let currentUserID = user.uid
        event.participants.append(currentUserID)
        
        let eventDict: [String: Any] = [
            "event title": event.title,
            "latitude": event.location.latitude,
            "longitude": event.location.longitude,
            "event address": event.address,
            "event date": event.date?.timeIntervalSince1970,
            "event description": event.description ?? "No description",
            "event participants": event.participants
        ]
        
        eventRef.updateChildValues(eventDict){ error, _ in
            if let error = error {
                print("Error updating event: \(error.localizedDescription)")
                completion(false)
            } else {
                print("event's participants list updated successfully.")
                completion(true)
            }
        }
        
        //event's participants list is updated, now updating user's events list
        var localEvent = event //for escaping inout paramater
        let safeEmail = DatabaseManager.makeSafeEmail(with: user.email!)
        let userRef = database.child("users").child(safeEmail)
        
        getUserData(with: safeEmail, completion: { returnedUser in
            if var returnedUser = returnedUser {
                
                returnedUser.events.append(localEvent.id)
                
                let userDict: [String: Any] = [
                    "User ID": returnedUser.id,
                    "first_name": returnedUser.firstName,
                    "last_name": returnedUser.lastName,
                    "events": returnedUser.events
                ]
                userRef.updateChildValues(userDict){ error, _ in
                    if let error = error {
                        print("Error updating user: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("user's events list updated successfully.")
                        completion(true)
                    }
                }
            } else {
                print("Failed to update event.")
            }})
        //user's events list is updated too
    }
    
    /*
    //todo check if you want fireBaseUser instead of a User
    //TODO Addition of user to event, works both for creation of event and a user clicking on JOIN
    public func addUserToEvent(user:inout User, act:String, event:inout Event, completion: @escaping (Bool) -> Void){
        
        //if it's an event creation so i insert the creator to the participants list directly :)
        if act == "JOIN" {
            let eventRef = database.child("events").child(event.id)
            
            //getting current user from database
            guard let fireBaseUser = FirebaseAuth.Auth.auth().currentUser else{
                print("cant retrieve user from database in addUserToEvent")
                return
            }
            let currentUserID = fireBaseUser.uid
            event.participants.append(currentUserID)
            
            let eventDict: [String: Any] = [
                "event title": event.title,
                "latitude": event.location.latitude,
                "longitude": event.location.longitude,
                "event address": event.address,
                "event date": event.date?.timeIntervalSince1970,
                "event description": event.description ?? "No description",
                "event participants": event.participants
            ]
            
            eventRef.updateChildValues(eventDict){ error, _ in
                if let error = error {
                    print("Error updating event: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("event's participants list updated successfully.")
                    completion(true)
                }
            }
        }
        
        
        //event's participants list is updated, now updating user's events list
        let safeEmail = DatabaseManager.makeSafeEmail(with: user.email)
        let userRef = database.child("users").child(safeEmail)
        user.events.append(event.id)
        let userDict: [String: Any] = [
            "User ID": user.id,
            "first_name": user.firstName,
            "last_name": user.lastName,
            "events": user.events
        ]
        
        userRef.updateChildValues(userDict){ error, _ in
            if let error = error {
                print("Error updating user: \(error.localizedDescription)")
                completion(false)
            } else {
                print("user's events list updated successfully.")
                completion(true)
            }
        }
        //user's events list is updated too
    }
     */
}

//for events creation and details
extension DatabaseManager{
    
    public enum DatabaseError: Error {
        case failedToFetch

        public var localizedDescription: String {
            switch self {
            case .failedToFetch:
                return "This means blah failed"
            }
        }
    }
    
    
    ///Inserts a new event to database
    public func insertEvent(with event: Event, completion: @escaping (Bool) -> Void){
        let eventValues: [String: Any] = [
            "event title": event.title,
            "latitude": event.location.latitude,
            "longitude": event.location.longitude,
            "event address": event.address,
            "event date": event.date?.timeIntervalSince1970,
            "event description": event.description ?? "No description",
            "event participants": event.participants
        ]
        
        
        
        database.child("events").child(event.id).setValue(eventValues) { error, _ in
            if let error = error {
                print("Failed to write to database in insertEvent: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func getAllEvents(completion: @escaping ([String: Event]) -> Void) {
        database.child("events").observeSingleEvent(of: .value) { (snapshot,error) in
            guard let eventSnapshots = snapshot.children.allObjects as? [DataSnapshot] else {
                completion([:])
                return
            }
            var events: [String: Event] = [:]
            //var events: [Event] = []
            
            for eventSnapshot in eventSnapshots {
                guard let eventData = eventSnapshot.value as? [String: Any],
                      let eventTitle = eventData["event title"] as? String,
                      let eventLatitude = eventData["latitude"] as? CLLocationDegrees,
                      let eventLongitude = eventData["longitude"] as? CLLocationDegrees,
                      let eventAddress = eventData["event address"] as? String,
                      let eventDate = eventData["event date"] as? Double,
                      let eventDesc = eventData["event description"] as? String,
                      let eventParticipants = eventData["event participants"] as? [String] //participants IDs
                else {
                    continue
                }
                
                let eventLocation = CLLocationCoordinate2D(latitude: eventLatitude, longitude: eventLongitude)
                
                var event = Event(id: eventSnapshot.key,
                                  title: eventTitle,
                                  location: eventLocation,
                                  address: eventAddress,
                                  date: Date(timeIntervalSince1970: eventDate),
                                  description: eventDesc,
                                  participants: eventParticipants)
                //event.id = eventSnapshot.key
                events[eventSnapshot.key] = event
            }
            completion(events)
        }
    }
    
    
    /*
    /// Fetches and returns all events for the user with passed in email
    public func getAllEventsForUser(for email: String, completion: @escaping (Result<[Event], Error>) -> Void) {
        database.child("\(email)/events").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }

            let events: [Event] = value.compactMap({ dictionary in
                guard let eventId = dictionary["id"] as? String,
                    let eventTitle = dictionary["title"] as? String,
                    let eventLocation = dictionary["location"] as? CLLocationCoordinate2D,
                    let eventAddress = dictionary["address"] as? String,
                    let eventDate = dictionary["date"] as? String,
                    let eventDesc = dictionary["description"] as? String,
                    let eventParticipants = dictionary["participants"] as? Bool else {
                        return nil
                }
                
                return Event(id : eventId, title: eventTitle, location: CLLocationCoordinate2D,
                             address: eventAddress, date: eventDate, description: eventDesc, participants: eventParticipants)
            })
            completion(.success(events))
        })
    }
    */
}
