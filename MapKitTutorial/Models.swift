//
//  Models.swift
//  MapKitTutorial
//
//  Created by Zohar Mosseri on 24/11/2023.
//

import Foundation
import SwiftUI
import MapKit
import UIKit
import FirebaseAuth
import MessageKit

// User struct representing user details
struct User: Identifiable {
    var id = UUID().uuidString
    var firstName: String
    var lastName: String
    var email: String
    var events: [String] //todo events as an ID not actually events!
    
    var profilePicFileName : String {
        let safeEmail = DatabaseManager.makeSafeEmail(with: email)
        return "\(safeEmail)_profile_picture.png"
    }
}

struct Event: Identifiable, Equatable {
    var id = UUID().uuidString //make sure you can't get the same number of id in 2 different occaisons
    let title: String
    let location: CLLocationCoordinate2D
    var address: String
    var date: Date?
    var description: String? //limit characters
    var participants: [String] // Participants are users, we are saving their users ID

    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Hostage {
    let imageName: String
    let name: String
    let age : Int
    let details: String
}




