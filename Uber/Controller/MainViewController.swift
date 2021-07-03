//
//  MainViewController.swift
//  Uber
//
//  Created by macbook-pro on 21/05/2020.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

enum ButtonState {
    case slide
    case clear
}
protocol MainViewControllerDelegate:AnyObject {
    func displayItems(items:[MKMapItem])
}

class MainViewController: UIViewController {
    var monitor = NewtworkChecker.shared
    var registeration : ListenerRegistration?
    var tripRegisteration : ListenerRegistration?

    let locationHandler = LocationHandler.shared
    weak var delegate : MainViewControllerDelegate?
    var topConstraint : NSLayoutConstraint!
    var heightConstraintTableView : NSLayoutConstraint!
    var bottomConstraintActionView : NSLayoutConstraint!
    var actionView : ActionView!
    var locationTableView = LocationTableView()
    
    var inputActivationView = LocationInputActivationView(image: UIImage(named: "uber"))
    var inputLocationView = LocationInputView()
    lazy var trackingButton : MKUserTrackingButton = {
        let mapUserTrackingButton = MKUserTrackingButton(mapView: self.mapView)
        mapUserTrackingButton.tintColor = .blackUber
        mapUserTrackingButton.translatesAutoresizingMaskIntoConstraints = false
        return mapUserTrackingButton
    }()
    lazy var searchingButton : UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.alpha = 0
        button.addTarget(self, action: #selector(handleSearchDrivers), for: .touchUpInside)
        let configuration = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 60))
        let image = UIImage(systemName: "magnifyingglass")
        image?.withConfiguration(configuration)
        button.setImage(image, for: .normal)
        button.backgroundColor = .blackUber
        button.layer.cornerRadius = 40/2
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var slideButton : UIButton = {
        let slideButton = UIButton(type: .system)
        slideButton.addTarget(self, action: #selector(handleSlideButton), for: .touchUpInside)
        slideButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        slideButton.translatesAutoresizingMaskIntoConstraints = false
        return slideButton
    }()
    var slideButtonState = ButtonState.slide
    
    var user : User! {
        didSet {
            guard user != nil else { return }
            inputLocationView.user = user
        }
    }
    
    var trip : Trip?
    
    
    lazy var mapView : MKMapView = {
        let map = MKMapView()
        map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAuthenticationAndConfigueUI()
    }
    func setupMapView(){
        locationTableView.locationDelegate = self
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.showsCompass = false
        mapView.userTrackingMode = .followWithHeading
        locationHandler.mapView = mapView
        inputActivationView.inputActivationDelegate = self
        inputLocationView.delegate = self
    }
    
    func checkAuthenticationAndConfigueUI() {
        DispatchQueue.main.async {
            if AUTH.currentUser == nil {
                let rootViewController = LoginViewController()
                let nav = UINavigationController(rootViewController: rootViewController)
                nav.navigationBar.barStyle = .black
                nav.navigationBar.isHidden = true
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: false, completion: nil)
            } else {
                self.fetchUser()
                self.configueUI()
                
            }
        }
    }
    
    func fetchUser() {
        UserService.shared.fetchUser { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.user = user
                self.locationHandler.userOption = user.userOption
                if user.userOption == .driver {
                    self.fetchTrip()
                    self.searchingButton.alpha = 0
                    self.inputActivationView.alpha = 0 
                } else {
                    UIView.animate(withDuration: 2) {
                     self.searchingButton.alpha = 1
                     self.inputActivationView.alpha = 1

                    }
                }
                

                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    func fetchTrip() {
        guard user.userOption == .driver else { return }
        registeration = TripService.shared.observeRequestedTrip { result in
            switch result {
            case .success(let trip):
                guard self.trip == nil else { return }
                self.trip = trip
                self.listenTrip(tripID: trip.tripID)
                let pickupController = PickupController(trip: trip)
                pickupController.modalPresentationStyle = .fullScreen
                self.present(pickupController, animated: true) {
                    self.locationHandler.stopUpdatingLocation()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    func configueUI() {
        view.addSubview(mapView)
        view.addSubview(inputActivationView)
        view.addSubview(locationTableView)
        view.addSubview(inputLocationView)
        view.addSubview(slideButton)
        view.addSubview(trackingButton)
        view.addSubview(searchingButton)
        inputLocationView.translatesAutoresizingMaskIntoConstraints = false
        topConstraint = inputLocationView.topAnchor.constraint(equalTo: view.topAnchor,constant: -300)
        heightConstraintTableView = locationTableView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            searchingButton.widthAnchor.constraint(equalToConstant: 40),
            searchingButton.heightAnchor.constraint(equalTo: searchingButton.widthAnchor),
            searchingButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            searchingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            slideButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            slideButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            trackingButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            trackingButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            slideButton.heightAnchor.constraint(equalToConstant: 50),
            slideButton.widthAnchor.constraint(equalTo: slideButton.heightAnchor),
            trackingButton.heightAnchor.constraint(equalToConstant: 40),
            trackingButton.widthAnchor.constraint(equalTo: trackingButton.heightAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            locationTableView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor),
            locationTableView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
            locationTableView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor),
            heightConstraintTableView,
            topConstraint,
            inputLocationView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            inputLocationView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        delegate = locationTableView
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupMapView()
    }
    @objc func handleSearchDrivers() {
        fetchDrivers()
    }
    func fetchDrivers() {
        guard let user = self.user,
              user.userOption == .rider else { return }
        self.locationHandler.fetchDrivers(from: 10000) { result in
            switch result {
            case .success(let driverType):
                DispatchQueue.main.async {
                    switch driverType {
                    case .enter(driver: let driver):
                        let annotation = DriverRiderAnnotation(user: driver)
                        self.mapView.addAnnotation(annotation)
                    case .exit(driver: let driver):
                        let driverAnnotations = self.mapView.annotations.compactMap({ $0 as? DriverRiderAnnotation }).filter { $0.user.uid == driver.uid }
                        self.mapView.removeAnnotations(driverAnnotations)
                    case .move(driver: let driver):
                        let newAnnotation = DriverRiderAnnotation(user: driver)
                        if let driverAnnotation = self.mapView.annotations.compactMap({ $0 as? DriverRiderAnnotation }).filter({ $0.user.uid == driver.uid }).first {
                            UIView.animate(withDuration: 1.5) {
                                driverAnnotation.coordinate = newAnnotation.coordinate
                            }
                        }
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    deinit {
        registeration?.remove()
    }
    func dismissTableLocation(_ completionHandler: (()-> Void)?) {
        UIView.animate(withDuration: 0.4) {
            self.heightConstraintTableView.constant = 0
            self.view.layoutIfNeeded()
        } completion: { _ in
            UIView.animate(withDuration: 0.4) {
                self.topConstraint.constant -= 300
                self.view.layoutIfNeeded()
            } completion: { _ in
                completionHandler?()
            }
        }
    }
    func presentTableLocation() {
        UIView.animate(withDuration: 0.4) {
            self.inputActivationView.alpha = 0
            self.slideButton.alpha = 0
            self.trackingButton.alpha = 0
            self.searchingButton.alpha = 0
        } completion: { _ in
            UIView.animate(withDuration: 0.4) {
                self.topConstraint.constant = 0
                self.view.layoutIfNeeded()
            } completion: { _ in
                UIView.animate(withDuration: 0.4) {
                    self.heightConstraintTableView.constant = self.view.bounds.height+20-self.inputLocationView.bounds.height
                    self.view.layoutIfNeeded()
                } completion: { _ in
                    self.locationHandler.stopUpdatingLocation()
                }
            }
        }
    }
    
}

extension MainViewController: LocationInputActivationViewDelegate {
    func handleLocationInputTapped(_ locationInput: LocationInputActivationView) {
        presentTableLocation()
    }
}
extension MainViewController: LocationInputViewDelegate {
    func handleSearchLocation(location: String?, locationInputView: LocationInputView) {
        guard let location = location else { return }
        
        //let request = MKLocalPointsOfInterestRequest(coordinateRegion: mapView.region)
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = location
        request.region = mapView.region
        request.resultTypes = [.address, .pointOfInterest]
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let response = response else { return }
            self.delegate?.displayItems(items: response.mapItems.filter({ $0.name != "" && $0.placemark.title != "" }))
        }
        
    }
    
    func handleBackButtonTapped(locationInputView: LocationInputView) {
        dismissTableLocation {
            self.defaultState()
//            UIView.animate(withDuration: 0.4) {
//                self.slideButton.alpha = 1
//                self.inputActivationView.alpha = 1
//                self.trackingButton.alpha = 1
//                self.searchingButton.alpha = 1
//            } completion: { _ in
//                self.locationHandler.startUpdatingLocation()
//            }
        }
    }
    
    
    
    
    @objc func handleSlideButton() {
        switch slideButtonState {
        case .slide:
            break
        case .clear:
            self.slideButtonState = .slide
            defaultState()
        }
        
    }
    
    func defaultState() {
        trip = nil
        guard let user = user else { return }
        switch user.userOption {
        case .rider:
            self.handleActionView(show: false, actionViewConfiguration: nil)
            UIView.animate(withDuration: 0.4) {
                self.mapView.removeOverlays(self.mapView.overlays)
                self.mapView.removeAnnotations(self.mapView.annotations.filter({ !($0 is MKUserLocation) }))
                self.mapView.setUserTrackingMode(.follow, animated: true)
                self.slideButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
                self.inputActivationView.alpha = 1
                self.trackingButton.alpha = 1
                self.searchingButton.alpha = 1
                self.slideButton.alpha = 1
            } completion: { _ in
                self.locationHandler.startUpdatingLocation()
                self.mapView.setUserTrackingMode(.follow, animated: true)
            }
        case .driver:
            self.handleActionView(show: false, actionViewConfiguration: nil)
            UIView.animate(withDuration: 0.4) {
                self.mapView.removeOverlays(self.mapView.overlays)
                self.mapView.removeAnnotations(self.mapView.annotations.filter({ !($0 is MKUserLocation) }))
                self.mapView.setUserTrackingMode(.follow, animated: true)
                self.slideButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            } completion: { _ in
                self.locationHandler.startUpdatingLocation()
                self.mapView.setUserTrackingMode(.follow, animated: true)
            }
        }
    }
    
    func handleAcceptTrip() {
        guard let trip = trip,
              let user = user,
              trip.state == .accepted  else { return }
        
        self.locationHandler.startUpdatingLocation()
        if user.userOption == .driver {
            let placemark = MKPlacemark(coordinate: trip.source)
            let mapItem = MKMapItem(placemark: placemark)
            let detination = mapItem
            setupDirection(destination: detination, .automobile, user: trip.rider)
            handleActionView(user: trip.rider,
                             destination: detination,
                             show: true, actionViewConfiguration: .tripAccepted)
        } else {
            if let location = trip.driver.location {
                let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)))
                self.mapView.removeOverlays(self.mapView.overlays)
                self.mapView.removeAnnotations(self.mapView.annotations.filter({ !($0 is MKUserLocation) }))
                setupDirection(destination: destination, .automobile, user: trip.driver)
            }
            let placemark = MKPlacemark(coordinate: trip.destination)
            let mapItem = MKMapItem(placemark: placemark)
            handleActionView(user: trip.driver,
                             destination:  mapItem,
                             show: true, actionViewConfiguration: .tripCanceled)
        }
    }
    
}

extension MainViewController: LocationTableViewDelegate {
    func didChooseLocation(mapItem: MKMapItem) {
        dismissTableLocation {
            self.handleActionView(user: self.user, destination: mapItem, show: true, actionViewConfiguration: .requestRide)
            self.setupDirection(destination: mapItem, .automobile, user: nil)
            self.slideButtonState = .clear
            UIView.animate(withDuration: 0.4) {
                self.slideButton.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp-1").withRenderingMode(.alwaysOriginal), for: .normal)
                self.slideButton.alpha = 1
            } completion: { _ in
            }
            
        }
    }
    func handleActionView(user: User? = nil, destination: MKMapItem? = nil, show : Bool, actionViewConfiguration: ActionViewConfiguration?) {
        if show {
            guard view.subviews.first(where: { $0 is ActionView }) == nil,
                  let user = user,
                  let destination = destination,
                  let actionViewConfiguration = actionViewConfiguration else { return }
            let actionView = ActionView(user: user, destination: destination, configuration: actionViewConfiguration)
            self.actionView = actionView
            actionView.delegate = self
            view.addSubview(actionView)
            let bottom = actionView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: 400)
            self.bottomConstraintActionView = bottom
            NSLayoutConstraint.activate([
                bottom,
                actionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                actionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                //locationTableView.heightAnchor.constraint(equalToConstant: )
            ])
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.4) {
                bottom.constant = 0
                self.view.layoutIfNeeded()
            }
        } else {
            guard let actionView = view.subviews.first(where: { $0 is ActionView }) as? ActionView else { return }
            UIView.animate(withDuration: 0.4) {
                self.bottomConstraintActionView.constant = 400
                self.view.layoutIfNeeded()
            } completion: { _ in
                actionView.removeFromSuperview()
            }
            
            
        }
        
    }
    func setupDirection(destination:MKMapItem , _ type :MKDirectionsTransportType, user: User?) {
        locationHandler.startUpdatingLocation()
        let request = MKDirections.Request()
        let placeMark = MKPlacemark(coordinate: mapView.userLocation.coordinate)
        request.source = MKMapItem(placemark: placeMark)
        request.destination = destination
        request.transportType = type
        request.requestsAlternateRoutes = true
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if let routes = response?.routes {
                let fastRoute = routes.min { $0.expectedTravelTime < $1.expectedTravelTime }!
                DispatchQueue.main.async {
                    let polyline = fastRoute.polyline
                    polyline.title = "fastRoute"
                    self.mapView.addOverlay(polyline)
                    if let user = user {
                        let pointAnnotation = DriverRiderAnnotation(user: user)
                        self.mapView.addAnnotation(pointAnnotation)
                    } else {
                        let pointAnnotation = MKPointAnnotation()
                        pointAnnotation.coordinate = destination.placemark.coordinate
                        self.mapView.addAnnotation(pointAnnotation)
                        
                    }
                    self.mapView.zoomToFit(annotations: self.mapView.annotations, polyline: polyline, bottomPading: self.actionView.bounds.height+40)
                    
                }
            }
        }
    }
    
    
}
extension MainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            guard let currentUser = user else { return nil }
            
            let annotationView = UserAnnotationView(user: currentUser,annotation: annotation, reuseIdentifier: nil)
            return annotationView
        }
        
        if let annotation = annotation as? DriverRiderAnnotation  {
            let annotationView = DriverRiderAnnotationView(user: annotation.user, annotation: annotation, reuseIdentifier: nil)
            return annotationView
        }
        if let annotation = annotation as? MKPointAnnotation {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
            annotationView.animatesDrop = true
            annotationView.pinTintColor = .black
            return annotationView
        }
        return nil
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.title == "fastRoute",
           let polyline = overlay as? MKPolyline {
            let render = MKGradientPolylineRenderer(polyline: polyline)
            render.setColors([.blueCyan,.blackUber], locations: [0,1])
            //createPath(render: render, polyline: polyline)
            return render
        }
        return MKOverlayRenderer()
    }
    
    func createPath(render: MKOverlayPathRenderer ,polyline:MKPolyline) {
        let path = CGMutablePath()
        let buffer = UnsafeMutableBufferPointer(start: polyline.points(), count: polyline.pointCount)
        let points = Array(buffer).map { render.point(for: $0) }
        DispatchQueue.global().async {
            path.catmullRomInterpolatedPoints(points: points, closed: false, alpha: 0.3)
            render.strokeColor = .blueCyan
            render.lineWidth = 10
            render.lineJoin = .round
            render.lineCap = .round
            render.path = path
        }
    }
    
}

extension MainViewController: ActionViewDelegate {
    func getDirectionTrip(actionView: ActionView, detination: CLLocationCoordinate2D) {
        setupDirections(to: MKMapItem(placemark: MKPlacemark(coordinate: detination)), .automobile)
    }
    func setupDirections(to destination:MKMapItem , _ type :MKDirectionsTransportType) {
        locationHandler.startUpdatingLocation()
        let request = MKDirections.Request()
        let placeMark = MKPlacemark(coordinate: mapView.userLocation.coordinate)
        request.source = MKMapItem(placemark: placeMark)
        request.destination = destination
        request.transportType = type
        request.requestsAlternateRoutes = true
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if let routes = response?.routes {
                let fastRoute = routes.min { $0.expectedTravelTime < $1.expectedTravelTime }!
                DispatchQueue.main.async {
                    fastRoute.steps.forEach { step in
                        print(step.distance)
                        print(step.instructions)
                        print(step.notice)
                    }
                }
            }
        }
    }
    func cancelTrip(actionView: ActionView) {
        guard user.userOption == .rider,
              let trip =  trip else { return }
        TripService.shared.updateTrip(tripID: trip.tripID, state: .canceled) { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
    }
    
    
    
    func uploadTrip(actionView: ActionView, detination: CLLocationCoordinate2D) {
        guard user.userOption == .rider else { return }
        shouldPresentLoadingView(true,message: "Finding you ride now...")
        handleActionView(show: false, actionViewConfiguration: nil)
        UserService.shared.uploadTrip(sourcePoint: mapView.userLocation.coordinate,
                                      destinationPoint: detination) { tripID ,error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let tripID = tripID else { return }
            self.listenTrip(tripID: tripID)
        }
    }

    func listenTrip(tripID: String) {
        tripRegisteration = TripService.shared.listenTrip(tripID: tripID) { result in
            switch result {
            case .success(let trip):
                self.trip = trip
                if trip.state == .accepted {
                    if self.user.userOption == .rider,
                       self.view.subviews.first(where: { $0 is UIVisualEffectView }) != nil {
                        self.shouldPresentLoadingView(false)
                    }
                    
                    self.handleAcceptTrip()
                }
                if trip.state == .canceled {
                    self.defaultState()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
