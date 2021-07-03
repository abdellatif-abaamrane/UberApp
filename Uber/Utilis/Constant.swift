//
//  Constant.swift
//  Uber
//
//  Created by macbook-pro on 21/05/2020.
//

import Foundation
import Firebase


let DB_RF = Firestore.firestore()
let REF_USERS = DB_RF.collection("users")
let REF_TRIPS = DB_RF.collection("trips")
let REF_USERTRIPS = DB_RF.collection("user-trips").document(AUTH.currentUser!.uid).collection("trips")

let REF_USERLOCATIONS = DB_RF.collection("user-locations").document(AUTH.currentUser!.uid).collection("locations")
let REF_USERSLOCATION = DB_RF.collection("users-locations")

let AUTH = Auth.auth()
let STORAGE_RF = Storage.storage().reference()
let STORAGE_PROFILE_IMAGES = STORAGE_RF.child("profile_images")
