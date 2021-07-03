//
//  User.swift
//  Uber
//
//  Created by macbook-pro on 21/05/2020.
//

import Foundation
import Firebase

enum UserOption: Int, CaseIterable {
    case rider
    case driver
    
    var description : String {
        switch self {
        case .rider:
            return "Rider"
        case .driver:
            return "Driver"
        }
    }
}


class User {
    var uid : String
    var fullname : String
    var username : String
    var email : String
    var bio : String
    var timestamp : Date
    var location : (latitude:Double, longitude: Double)?
    var userOption : UserOption
    var profileImageURL : String
    var isCurrentUser : Bool {
        AUTH.currentUser?.uid == uid
    }
    init(uid:String,dictionary:[String:Any]) {
        self.uid = uid
        if let location = dictionary["location"] as? GeoPoint {
            self.location = (location.latitude,location.longitude)
        }
        
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.bio = dictionary["bio"] as? String ?? ""
        self.profileImageURL = dictionary["profileImageURL"] as? String ?? ""
        let timestamp = dictionary["timestamp"] as? Timestamp
        self.timestamp = timestamp?.dateValue() ?? Date()
        let optionRawValue = dictionary["userOption"] as? Int ?? 0
        self.userOption = UserOption(rawValue: optionRawValue) ?? .rider
    }
}
