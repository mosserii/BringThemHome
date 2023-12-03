//
//  MyAnnotation.swift
//  MapKitTutorial
//
//  Created by Zohar Mosseri on 25/11/2023.
//

import Foundation
import MapKit

class MyAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var EVENT_ID: String?
    var title: String?

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

class PrintShopAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}


