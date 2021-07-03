//
//  LocationInputActivationView.swift
//  Uber
//
//  Created by macbook-pro on 21/05/2020.
//

import UIKit

protocol LocationInputActivationViewDelegate: AnyObject {
    func handleLocationInputTapped(_ locationInput:LocationInputActivationView)
}

class LocationInputActivationView: UITextField {
    init(image: UIImage? = nil) {
        self.image = image
        super.init(frame: .zero)
    }
    weak var inputActivationDelegate : LocationInputActivationViewDelegate?
    var image : UIImage?
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        configureUI()
    }

    func configureUI() {
        translatesAutoresizingMaskIntoConstraints = false
        guard let superview = superview else { return }
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 50),
            widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: 0.75),
            topAnchor.constraint(equalTo: superview.topAnchor, constant: 80),
            centerXAnchor.constraint(equalTo: superview.centerXAnchor)
        ])
        layoutIfNeeded()
        backgroundColor = .white
        leftViewMode = .always

        let imageView = UIImageView(image: UIImage(image: image!, size: bounds.height) ?? UIImage(color: .blackUber, size: bounds.height))
        
        leftView = imageView
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        attributedPlaceholder = NSAttributedString(string: "Where to?",
                                                   attributes: [.font : UIFont.systemFont(ofSize: 22),
                                                                .foregroundColor:UIColor.lightGray])
        layer.shadowColor = UIColor.blackUber.cgColor
        layer.shadowRadius = 3
        var transform = CGAffineTransform(scaleX: 1, y: 1)
        layer.shadowPath = CGPath(roundedRect: bounds, cornerWidth: 10, cornerHeight: 10, transform: &transform)
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        layer.shadowOpacity = 0.8
        alpha = 0
        layer.cornerRadius = 10
        delegate = self
    }
}
extension LocationInputActivationView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        inputActivationDelegate?.handleLocationInputTapped(self)
        endEditing(true)
    }
}
