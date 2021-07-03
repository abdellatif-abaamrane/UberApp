//
//  Trip.swift
//  Uber
//
//  Created by macbook-pro on 23/05/2020.
//

import CoreLocation
import Firebase



struct Trip {
    var tripID : String
    var rider : User
    var driver : User
    var state : TripState
    var timestamp : Date

    var source : CLLocationCoordinate2D
    var destination : CLLocationCoordinate2D
    
    
    init(tripID:String,rider: User, driver: User,dictionary:[String:Any]) {
        self.tripID = tripID
        let timestamp = dictionary["timestamp"] as? Timestamp
        self.timestamp = timestamp?.dateValue() ?? Date()
        self.state = TripState(rawValue: dictionary["state"] as? Int ?? 0)  ?? .completed
        let source = dictionary["source"] as? GeoPoint ?? GeoPoint(latitude: 0, longitude: 0)
        self.source = CLLocationCoordinate2D(latitude: source.latitude, longitude: source.longitude)
        let destination = dictionary["destination"] as? GeoPoint ?? GeoPoint(latitude: 0, longitude: 0)
        self.destination = CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude)
        self.driver = driver
        self.rider = rider
    }

}

enum TripState: Int {
    case requested
    case accepted
    case inProgress
    case completed
    case canceled

}
