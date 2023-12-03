//
//  EventManager.swift
//  MapKitTutorial
//
//  Created by Zohar Mosseri on 24/11/2023.
//

import Foundation
import SwiftUI
import MapKit
import UIKit
import CoreLocation
import FirebaseAuth


protocol EventAddedDelegate: AnyObject {
    func didAddNewEvent(_ event: Event)
}



class EventManager {
    static let shared = EventManager()

    //todo array ? : //private var events: [Event] = []
    
    
    //when adding a new event, a new annotation should appear on the main Map // todo check if = nil
    weak var eventAddedDelegate: EventAddedDelegate?
    
    //todo big check on how to run my events list
    var events: [String: Event] = [:]
    
    /*
    func createEvent(eventTitle: String, eventLocation: CLLocationCoordinate2D, eventDescription: String, eventDate: Date, eventAddress: String, eventCreator: User) {
        
        let newEvent = Event(title: eventTitle, location: eventLocation, address: eventAddress, date: eventDate, description: eventDescription,
                             participants: [eventCreator])
        events[newEvent.id] = newEvent
    }
     */
     
    
    func createEvent(eventTitle: String, eventLocation: CLLocationCoordinate2D, addr: String, date: Date, desc: String) {
        let newEvent = Event(title: eventTitle, location: eventLocation, address: addr, date: date, description: desc, participants: [])
        events[newEvent.id] = newEvent
        //events.append(newEvent)
    }
    
    /*TODOOOOOOO
    // Add the user to the participants list of the event
    func addParticipant(user: User, to event: Event) {
        event.addParticipant(user: user)
    }
    */
    

    func getAllEvents() -> [Event] {
        return Array(events.values)
    }
    
    // Function to get a specific event by its ID
    func getEvent(withId eventId: String) -> Event? {
        return events[eventId]
    }
    

    func addParticipantToEvent(user: User, toEvent: inout Event) {
        toEvent.participants.append(user.id)
    }
    


}


class UserManager {
    static let shared = UserManager()

    
    //key is my user id
    var users: [String: User] = [:]
    


}

