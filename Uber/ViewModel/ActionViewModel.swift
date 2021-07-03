//
//  ActionViewModel.swift
//  Uber
//
//  Created by macbook-pro on 23/05/2020.
//

import Foundation
import MapKit


class ActionViewModel {
    let actionView : ActionView
    let user: User
    let destination: MKMapItem

    init(actionView: ActionView,user: User, destination: MKMapItem) {
        self.actionView = actionView
        self.user = user
        self.destination = destination
    }
    
    func configueActionView() {
        switch user.userOption {
        case .rider:
            switch actionView.configuration {
            case .tripAccepted:
                actionView.confirmButton.setTitle(ButtonAction.getDirections.description, for: .normal)
            case .requestRide:
                actionView.confirmButton.setTitle(ButtonAction.requestRide.description, for: .normal)
            case .pickupPassenger:
                break
            case .tripInProgress:
                break
            case .endTrip:
                break
            case .tripCanceled:
                break
            }
        case .driver:
            switch actionView.configuration {
            case .tripAccepted:
                break
            case .requestRide:
                break
            case .pickupPassenger:
                break
            case .tripInProgress:
                break
            case .endTrip:
                break
            case .tripCanceled:
                actionView.confirmButton.setTitle(ButtonAction.cancel.description, for: .normal)
            }
        }
        
        if let url = URL(string: user.profileImageURL) {
            actionView.driverProfileImage.fetchImage(url: url)
        }
        actionView.driverName.text = user.fullname
        coder()
    }
    func coder() {
        let coder = CLGeocoder()
        if destination.name == "Unknown Location" {
            coder.reverseGeocodeLocation(CLLocation(latitude: destination.placemark.coordinate.latitude, longitude: destination.placemark.coordinate.longitude)) { placemarks, error in
                if let error = error {
                    print(error.localizedDescription)
                    self.actionView.nameLabel.text = self.destination.name
                    self.actionView.addressLabel.text = self.destination.placemark.title
                    return
                }
                if let placemark = placemarks?.first {
                   let mkPlacemark = MKPlacemark(placemark: placemark)
                    self.actionView.nameLabel.text = mkPlacemark.name
                    self.actionView.addressLabel.text = mkPlacemark.title
                }
            }
        } else {
            self.actionView.nameLabel.text = self.destination.name
            self.actionView.addressLabel.text = self.destination.placemark.title
        }
    }
}
