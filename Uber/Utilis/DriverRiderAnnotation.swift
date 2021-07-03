//
//  DriverAnnotation.swift
//  Uber
//
//  Created by macbook-pro on 22/05/2020.
//

import MapKit
import UIKit


class DriverRiderAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var user : User
    init(user: User) {
        self.user = user
        if let location = user.location {
            self.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        } else {
            self.coordinate = CLLocationCoordinate2D()
        }
    }
}
class DriverRiderAnnotationView : MKAnnotationView {
    init(user: User,annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        if let url = URL(string: user.profileImageURL) {
            fetchImage(url: url)
        }
        
        
        scalesLargeContentImage = true
        isOpaque = false
        isDraggable = true
        
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil {
            UIView.animate(withDuration: 0.4) {
                self.alpha = 0
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class UserAnnotationView : MKAnnotationView {
    init(user: User,annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        if let url = URL(string: user.profileImageURL) {
            fetchImage(url: url)
        }    }
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil {
            UIView.animate(withDuration: 0.4) {
                self.alpha = 0
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
