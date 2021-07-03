//
//  ActionView.swift
//  Uber
//
//  Created by macbook-pro on 23/05/2020.
//

import UIKit
import MapKit

protocol ActionViewDelegate: AnyObject {
    func uploadTrip(actionView: ActionView, detination: CLLocationCoordinate2D)
    func cancelTrip(actionView: ActionView)
    func getDirectionTrip(actionView: ActionView,detination: CLLocationCoordinate2D)

}

enum ActionViewConfiguration {
    case requestRide
    case tripCanceled

    case tripAccepted
    case pickupPassenger
    case tripInProgress
    case endTrip

}
enum ButtonAction: CustomStringConvertible {
    case requestRide
    case cancel

    case getDirections
    case pickup
    case dropOff
    
    var description : String {
        switch self {
        case .requestRide:
            return "CONFIRM UBERX"
        case .cancel:
            return "CANCEL RIDE"
        case .getDirections:
            return "GET DIRECTIONS"
        case .pickup:
            return "PICKUP PASSENGER"
        case .dropOff:
            return "DROP OFF PASSENGER"
        }
    }
    

}

class ActionView: UIView {
    weak var delegate : ActionViewDelegate?
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name Label"
        label.numberOfLines = 1
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = .white

        return label
    }()
    lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.text = "Address Label"
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = .lightGray
        return label
    }()
    lazy var driverProfileImage: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.automatic))
        imageView.backgroundColor = .white
        imageView.tintColor = .blackUber
        imageView.layer.cornerRadius = 50/2
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var driverName: UILabel = {
        let label = UILabel()
        label.text = "Driver Name"
        label.numberOfLines = 1
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(handleConfirmButtonTapped), for: .touchUpInside)
        button.setTitle("CONFIRM", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor.white.cgColor
        button.backgroundColor = .blackUber
        return button
    }()
    
    var modelView: ActionViewModel {
        return ActionViewModel(actionView: self, user: user, destination: destination)
    }
    let user : User
    let destination : MKMapItem
    let configuration : ActionViewConfiguration
    init(user:User, destination: MKMapItem, configuration:ActionViewConfiguration) {
        self.user = user
        self.destination = destination
        self.configuration = configuration
        super.init(frame: .zero)
        configueUI()
        modelView.configueActionView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configueUI() {
        backgroundColor = .blackUber
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.blackUber.cgColor
        layer.shadowRadius = 3
        var transform = CGAffineTransform(scaleX: 1, y: 1)
        layer.shadowPath = CGPath(roundedRect: bounds, cornerWidth: 10, cornerHeight: 10, transform: &transform)
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        layer.shadowOpacity = 0.8
        layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
        let stackView = UIStackView(arrangedSubviews: [nameLabel,addressLabel])
        stackView.distribution = .fillProportionally
        stackView.spacing = 0
        stackView.alignment = .center
        stackView.axis = .vertical
        let p1 = nameLabel.contentCompressionResistancePriority(for: .vertical)
        let p2 = addressLabel.contentCompressionResistancePriority(for: .vertical)
        let p3 = driverName.contentCompressionResistancePriority(for: .vertical)
        let p4 = driverProfileImage.contentCompressionResistancePriority(for: .vertical)
        driverProfileImage.setContentCompressionResistancePriority(p4-1, for: .vertical)
        nameLabel.setContentCompressionResistancePriority(p1+1, for: .vertical)
        addressLabel.setContentCompressionResistancePriority(p2+1, for: .vertical)
        driverName.setContentCompressionResistancePriority(p3+1, for: .vertical)

        let stackView1 = UIStackView(arrangedSubviews: [driverProfileImage,driverName])
        stackView1.distribution = .fillProportionally
        stackView1.spacing = 5
        stackView1.alignment = .center
        stackView1.axis = .vertical
        
        let stackView2 = UIStackView(arrangedSubviews: [stackView,stackView1])
        stackView2.distribution = .fillProportionally
        stackView2.spacing = 8
        stackView2.alignment = .center
        stackView2.axis = .vertical
        
        let divider = UIView()
        divider.backgroundColor = .white
        
        let mainStackView = UIStackView(arrangedSubviews: [stackView2,divider,confirmButton])
        mainStackView.distribution = .fillProportionally
        mainStackView.spacing = 12
        mainStackView.alignment = .center
        mainStackView.axis = .vertical
        
        
        translatesAutoresizingMaskIntoConstraints = false
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView1.translatesAutoresizingMaskIntoConstraints = false
        divider.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        driverProfileImage.translatesAutoresizingMaskIntoConstraints = false
addSubview(mainStackView)
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            mainStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
            mainStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
            mainStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -28),
            stackView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
            stackView1.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
            stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            stackView1.heightAnchor.constraint(greaterThanOrEqualToConstant: 70),

            divider.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
            confirmButton.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
            divider.heightAnchor.constraint(equalToConstant: 0.4),
            confirmButton.heightAnchor.constraint(equalToConstant: 50),
            driverProfileImage.widthAnchor.constraint(equalTo: confirmButton.heightAnchor),
            driverProfileImage.heightAnchor.constraint(equalTo: confirmButton.heightAnchor),
        ])
        
    }
    @objc func handleConfirmButtonTapped() {
        switch configuration {
        case .tripAccepted:
            if user.userOption == .rider {
                delegate?.getDirectionTrip(actionView: self, detination: destination.placemark.coordinate)
            }
        case .requestRide:
            delegate?.uploadTrip(actionView: self, detination: destination.placemark.coordinate)
        case .pickupPassenger:
            break
        case .tripInProgress:
            break
        case .endTrip:
            break
        case .tripCanceled:
            if user.userOption == .driver {
                delegate?.cancelTrip(actionView: self)
            }
        }
    }
}
