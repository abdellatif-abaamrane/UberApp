//
//  UserService.swift
//  Uber
//
//  Created by macbook-pro on 21/05/2020.
//

import Firebase
import CoreLocation
import GeoFire


enum DriverType {
    case enter(driver: User)
    case exit(driver: User)
    case move(driver: User)
    
}

struct UserService {
    static let shared = UserService()
    
    func updateUserData(user:User, _ completion: @escaping (Error?) -> Void) {
        let data = ["username":user.username,
                    "fullName":user.fullname,
                    "bio":user.bio,
                    "profileImageURL":user.profileImageURL]
        REF_USERS.document(user.uid).setData(data, merge: true, completion: completion)
    }
    func updateLocation(location:CLLocationCoordinate2D, _ completion: @escaping (Error?) -> Void) {
        guard let currentUser = AUTH.currentUser else { return }
        let geoPoint = GeoPoint(latitude: location.latitude, longitude: location.longitude)
        REF_USERS.document(currentUser.uid).setData(["location" : geoPoint], merge: true, completion: completion)
    }
    func sendLocation(location:CLLocationCoordinate2D, _ completion: @escaping (Error?) -> Void) {
        guard let currentUser = AUTH.currentUser else { return }
        let geoPoint = GeoPoint(latitude: location.latitude, longitude: location.longitude)
        let geoHash = GFUtils.geoHash(forLocation: location)
        let timestamp = Date()
        DispatchQueue.global().async {
            REF_USERSLOCATION.document(currentUser.uid).setData(["geoPoint" : geoPoint,
                                                                 "geoHash" : geoHash,
                                                                 "timestamp": timestamp], merge: true) { error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                REF_USERLOCATIONS.addDocument(data:["location" : geoPoint,
                                                    "geoHash" : geoHash,
                                                    "timestamp": timestamp]) { error in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    updateLocation(location: location, completion)
                }
                                                                 }
        }

    }
    func fetchDrivers(riderLocation: CLLocationCoordinate2D ,radiusInKilometers: Double,_ completionHandler: @escaping (Result<DriverType, Error>) -> Void) {
        DispatchQueue.global().async {
            let queryBounds = GFUtils.queryBounds(forLocation: riderLocation, withRadius: radiusInKilometers)
            let queries = queryBounds.compactMap { query -> Query? in
                return REF_USERSLOCATION.order(by: "geoHash").start(at: [query.startValue]).end(at: [query.endValue])
            }
            queries.forEach { query in
                query.addSnapshotListener { snapshot, error in
                    if let error = error {
                        completionHandler(.failure(error))
                        return
                    }
                    guard let snapshot = snapshot else { return }
                    if !snapshot.documentChanges.isEmpty {
                        let enteredDriver = snapshot.documentChanges.filter({ $0.type == .added }).map({ $0.document })
                        enteredDriver.forEach { s in
                            fetchUser(uid: s.documentID) { result in
                                switch result {
                                case .success(let user):
                                    completionHandler(.success(.enter(driver: user)))
                                case .failure(let error):
                                    completionHandler(.failure(error))
                                }
                            }
                        }
                        let exitDriver = snapshot.documentChanges.filter({ $0.type == .removed }).map({ $0.document })
                        exitDriver.forEach { s in
                            fetchUser(uid: s.documentID) { result in
                                switch result {
                                case .success(let user):
                                    completionHandler(.success(.exit(driver: user)))
                                case .failure(let error):
                                    completionHandler(.failure(error))
                                }
                            }
                        }
                        let movedDriver = snapshot.documentChanges.filter({ $0.type == .modified }).map({ $0.document })
                        movedDriver.forEach { s in
                            fetchUser(uid: s.documentID) { result in
                                switch result {
                                case .success(let user):
                                    completionHandler(.success(.move(driver: user)))
                                case .failure(let error):
                                    completionHandler(.failure(error))
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    func fetchUser(_ completionHandler: @escaping (Result<User, Error>) -> Void) {
        guard let uid = AUTH.currentUser?.uid else { return }
        REF_USERS.document(uid).addSnapshotListener { userSnapshot, error in
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            if let userSnapshot = userSnapshot,
               let data =  userSnapshot.data() {
                let user = User(uid: userSnapshot.documentID, dictionary: data)
                completionHandler(.success(user))
            }
        }
    }
    func fetchUser(uid: String,_ completionHandler: @escaping (Result<User, Error>) -> Void) {
        REF_USERS.document(uid).getDocument(source: .default) { userSnapshot, error in
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            if let userSnapshot = userSnapshot,
               let data =  userSnapshot.data() {
                let user = User(uid: userSnapshot.documentID, dictionary: data)
                completionHandler(.success(user))
            }
        }
    }
    func fetchUser(userOption: UserOption,_ completionHandler: @escaping (Result<User, Error>) -> Void) {
        REF_USERS.whereField("userOption", isEqualTo: userOption.rawValue).getDocuments(source: .default) { userSnapshot, error in
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            if let userSnapshot = userSnapshot,
               let user = userSnapshot.documents.first {
                let user = User(uid: user.documentID, dictionary: user.data())
                completionHandler(.success(user))
            }
        }
    }
    func fetchUsers(_ completionHandler: @escaping (Result<[User], Error>) -> Void) {
        let source = FirestoreSource.default
        REF_USERS.getDocuments(source: source) { snapshot, error in
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            if let snapshot = snapshot {
                let users = snapshot.documents.map({ user in
                    User(uid: user.documentID, dictionary: user.data())
                })
                completionHandler(.success(users))
            }
        }
    }
    func uploadTrip(sourcePoint: CLLocationCoordinate2D, destinationPoint: CLLocationCoordinate2D, completion: @escaping ((String?, Error?) -> Void)) {
        guard let uid = AUTH.currentUser?.uid else { return }
        let sourceGeoPoint = GeoPoint(latitude: sourcePoint.latitude, longitude: sourcePoint.longitude)
        let destinationGeoPoint = GeoPoint(latitude: destinationPoint.latitude, longitude: destinationPoint.longitude)
        let tripState = TripState.requested.rawValue
        let ref = REF_TRIPS.document()
        ref.setData(["source" : sourceGeoPoint,
                     "destination": destinationGeoPoint,
                     "rider":uid,
                     "state":tripState,
                     "timestamp":Date()], merge: true) { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            REF_USERTRIPS.document(ref.documentID).setData([ : ]) { error in
                completion(ref.documentID,error)
            }
        }
        
        
    }


}
