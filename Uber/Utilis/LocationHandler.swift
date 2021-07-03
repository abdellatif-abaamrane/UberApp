//
//  LocationHandler.swift
//  Uber
//
//  Created by macbook-pro on 22/05/2020.
//

import CoreLocation
import MapKit

import UIKit



class LocationHandler: NSObject {
    static let shared  = LocationHandler()
    private var locationManager = CLLocationManager()
    var userOption : UserOption?
    private var location : CLLocation? {
        didSet {
            sendLocation()
        }
    }
    var mapView : MKMapView? {
        didSet {
            startUpdatingLocation()
        }
    }
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
    }
    func sendLocation() {
        guard let location = location else { return }
        UserService.shared.sendLocation(location: location.coordinate) { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
    }

    func fetchDrivers(from radius: Double, _ completionHandler: @escaping (Result<DriverType, Error>) -> Void) {
        guard let location = mapView?.userLocation.coordinate else { return }
        UserService.shared.fetchDrivers(riderLocation: location, radiusInKilometers: radius, completionHandler)
    }
    private func checkPermission(_ closure: ()->Void) {
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied,.restricted:
            let alert = UIAlertController(title: "Alert", message: "Enable the Location in the Settings App", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Go to Settings App", style: .default, handler: { _ in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                          options: [:],
                                          completionHandler: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            //present(alert, animated: true, completion: nil)
        case .authorizedWhenInUse, .authorizedAlways:
            closure()
        default:
            break
        }
    }
    func startUpdatingLocation() {
        checkPermission {
            locationManager.startUpdatingLocation()
        }
    }
    func stopUpdatingLocation() {
        checkPermission {
            locationManager.stopUpdatingLocation()
        }
    }
    var lastLocation = CLLocation()
}

extension LocationHandler: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = locationManager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        if self.location == nil && userOption != nil {
            self.location = location
        }
        
        if self.location != nil {
            guard 100 < location.distance(from: self.location!) else { return }
            self.location = location
        }
        
        
    }
}
