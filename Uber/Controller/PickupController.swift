//
//  PickupController.swift
//  Uber
//
//  Created by macbook-pro on 23/05/2020.
//

import UIKit
import CoreLocation
import MapKit


class PickupController: UIViewController {
    
    lazy var imageDestinationView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var label : UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Would you like to pick up this passenger?"
        label.numberOfLines = 1
        let p = label.contentCompressionResistancePriority(for: .vertical)
        label.setContentCompressionResistancePriority(p + 1, for: .vertical)
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var acceptTripButton : UIButton = {
        let acceptButton = UIButton()
        acceptButton.backgroundColor = .white
        acceptButton.setTitle("Accept", for: .normal)
        acceptButton.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        acceptButton.setTitleColor(.blackUber, for: .normal)
        acceptButton.layer.cornerRadius = 4
        acceptButton.addTarget(self, action: #selector(handleAcceptTrip), for: .touchUpInside)
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        return acceptButton
    }()
    lazy var cancelButton : UIButton = {
        let cancelButton = UIButton()
        cancelButton.setImage(#imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysTemplate), for: .normal)
        cancelButton.tintColor = .white
        cancelButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        return cancelButton
    }()
    
    let trip : Trip
    init(trip: Trip) {
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configueUI()
    }
    @objc func handleDismiss() {
        (presentingViewController as! MainViewController).trip = nil
        dismiss(animated: true, completion: nil)
    }
    @objc func handleAcceptTrip() {
        isAccepting = true
        TripService.shared.updateTrip(tripID: trip.tripID, state: .accepted) { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func configueUI() {
        view.backgroundColor = .blackUber
        let stackView = UIStackView(arrangedSubviews: [imageDestinationView,label,acceptTripButton])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            stackView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            imageDestinationView.widthAnchor.constraint(equalToConstant: 300),
            imageDestinationView.heightAnchor.constraint(equalTo: imageDestinationView.widthAnchor),
            acceptTripButton.heightAnchor.constraint(equalToConstant: 50),
            label.heightAnchor.constraint(equalToConstant: 40),
            acceptTripButton.widthAnchor.constraint(equalTo: imageDestinationView.widthAnchor, constant: -50)
        ])
        snapshot(location: trip.destination) { result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.setup(image: image, size: 300)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    func setup(image: UIImage,size:CGFloat) {
        
        
        let imageLayer = CALayer()
        imageLayer.contents = UIImage(named: "uber")?.withRenderingMode(.alwaysTemplate).withTintColor(.white).cgImage
        imageLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        imageLayer.position = CGPoint(x:imageDestinationView.layer.bounds.midX , y: imageDestinationView.layer.bounds.midY)
        imageLayer.bounds = imageDestinationView.layer.bounds
        imageLayer.cornerRadius = size/2
        imageLayer.masksToBounds = true
        
        let transition =  CATransition()
        imageLayer.contents = image.cgImage
        transition.isRemovedOnCompletion = true
        transition.type = .reveal
        transition.subtype = .fromTop

        transition.duration = 0.4
        imageLayer.add(transition, forKey: nil)
        
        let path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: size, height: size)))
        let circle = CAShapeLayer()
        circle.path = path.cgPath
        circle.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circle.position = CGPoint(x:imageDestinationView.layer.bounds.midX , y: imageDestinationView.layer.bounds.midY)
        circle.bounds = imageDestinationView.layer.bounds
        circle.fillColor = UIColor.systemPink.cgColor
    
        let anim = CABasicAnimation(keyPath: "opacity")
        anim.fromValue = 0
        anim.toValue = 0.6
        anim.duration = 1
        anim.autoreverses = true
        anim.repeatCount = .greatestFiniteMagnitude
        
        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = 1
        scaleAnim.toValue = 1.4
        scaleAnim.duration = 1
        scaleAnim.autoreverses = true
        scaleAnim.repeatCount = .greatestFiniteMagnitude
        
        let group = CAAnimationGroup()
        group.animations = [anim,scaleAnim]
        group.autoreverses = true
        group.repeatCount = .greatestFiniteMagnitude
        group.duration = 1
        circle.add(group, forKey: nil)
        
        
        let circle2 = CAShapeLayer()
        circle2.path = path.cgPath
        circle2.strokeEnd = 0
        circle2.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circle2.position = CGPoint(x:imageDestinationView.layer.bounds.midX , y: imageDestinationView.layer.bounds.midY)
        circle2.bounds = imageDestinationView.layer.bounds.inset(by: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15))
        circle2.fillColor = UIColor.clear.cgColor
        circle2.strokeColor = UIColor.systemPurple.cgColor
        circle2.lineWidth = 30
        circle2.lineCap = .round
        circle2.lineJoin = .round
        let duration = 10.0
        let strokeAnim = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnim.fromValue = circle2.strokeEnd
        strokeAnim.toValue =  1
        strokeAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        strokeAnim.duration = duration
        strokeAnim.isRemovedOnCompletion = true
        strokeAnim.isAdditive = true
        let animOpacity = CABasicAnimation(keyPath: "opacity")
        animOpacity.fromValue = 1
        animOpacity.toValue = 0
        animOpacity.beginTime = duration-0.5
        animOpacity.duration = 0.5

        let group2 = CAAnimationGroup()
        group2.delegate = self
        group2.animations = [strokeAnim,animOpacity]
        group2.duration = duration
        circle2.add(group2, forKey: nil)
        
        
        
        let transition2 =  CATransition()
        imageDestinationView.layer.addSublayer(circle)
        imageDestinationView.layer.addSublayer(circle2)
        imageDestinationView.layer.addSublayer(imageLayer)
        transition2.subtype = .fromRight
        transition2.type = .fade
        transition2.duration = 0.4
        imageDestinationView.layer.add(transition2, forKey: nil)


    }
    
    func snapshot(location: CLLocationCoordinate2D,_ completionHandler: @escaping (Result<UIImage,Error>)->Void) {
        let options = MKMapSnapshotter.Options()
        options.mapRect = MKMapRect(origin: MKMapPoint(location), size: MKMapSize(width: 200, height: 300))
        let shotter = MKMapSnapshotter(options: options)
        
        shotter.start(with: .main) { snapshot, error in
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            guard let snapshot = snapshot else { return }
            completionHandler(.success(snapshot.image))
        }
    }
    
    var isAccepting = false
}
extension PickupController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag && !isAccepting {
            dismiss(animated: true, completion: nil)
        }
    }
}
