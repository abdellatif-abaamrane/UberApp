//
//  TripService.swift
//  Uber
//
//  Created by macbook-pro on 23/05/2020.
//

import Firebase




struct TripService {
    static let shared = TripService()
    func observeRequestedTrip(_ completionHandler: @escaping (Result<Trip,Error>)->Void) -> ListenerRegistration? {
        guard let uid = AUTH.currentUser?.uid else {return nil}
        return REF_TRIPS.whereField("state", isEqualTo: TripState.requested.rawValue).addSnapshotListener { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let snapshot = snapshot else { return }
            snapshot.documentChanges.filter({ $0.type == .added }).map { $0.document }.forEach { snapshot in
                guard let riderID = snapshot.data()["rider"] as? String else { return }
                UserService.shared.fetchUser(uid: uid) { result in
                    switch result {
                    case .success(let driver):
                        UserService.shared.fetchUser(uid: riderID) { result in
                            switch result {
                            case .success(let rider):
                                let trip = Trip(tripID: snapshot.documentID, rider: rider, driver: driver, dictionary: snapshot.data())
                                completionHandler(.success(trip))
                            case .failure(let error):
                                completionHandler(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completionHandler(.failure(error))
                    }
                }
            }
        }
    }
    func updateTrip(tripID: String,state:TripState,_ completionHandler: @escaping (Error?) -> Void) {
        guard let uid = AUTH.currentUser?.uid else { return }
        REF_TRIPS.document(tripID).setData(["state" : state.rawValue,
                                            "driver": uid], merge: true, completion: completionHandler)
    }
    func listenTrip(tripID: String,_ completionHandler: @escaping (Result<Trip,Error>) -> Void) -> ListenerRegistration? {
        return  REF_TRIPS.document(tripID).addSnapshotListener { snapshot, error in
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            guard let snapshot = snapshot,
                  let data = snapshot.data(),
                  let driverID = snapshot.data()?["driver"] as? String,
                  let riderID = snapshot.data()?["rider"] as? String else { return }
            
            UserService.shared.fetchUser(uid: driverID) { result in
                switch result {
                case .success(let driver):
                    UserService.shared.fetchUser(uid: riderID) { result in
                        switch result {
                        case .success(let rider):
                            let trip = Trip(tripID: snapshot.documentID, rider: rider, driver: driver, dictionary: data)
                            completionHandler(.success(trip))
                        case .failure(let error):
                            completionHandler(.failure(error))
                        }
                    }
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
            
        }
    }
}
