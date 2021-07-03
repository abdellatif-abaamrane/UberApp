//
//  LocationInputView.swift
//  Uber
//
//  Created by macbook-pro on 21/05/2020.
//

import UIKit
protocol LocationInputViewDelegate: AnyObject {
    func handleBackButtonTapped(locationInputView: LocationInputView)
    func handleSearchLocation(location: String?,locationInputView: LocationInputView)

}
class LocationInputView: UIView {
    //MARK: - Properties
    var user: User? {
        didSet {
            configue()
        }
    }
    weak var delegate : LocationInputViewDelegate?
    private let backButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp-1").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleBackButtonTapped), for: .touchUpInside)
        return button
    }()
    var fillNameLabel : UILabel = {
        let label = UILabel()
        label.text = "Hello World"
        label.layer.sublayerTransform = CATransform3DMakeTranslation(-48, 0, 0)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    private lazy var sourceLocationField : UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 8
        textField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.white.cgColor
        textField.attributedPlaceholder = NSAttributedString(string: "Current Location", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.5)])
        textField.textColor = UIColor.white
        textField.tintColor = UIColor.white
        textField.backgroundColor = UIColor(white: 0, alpha: 0.1)
        return textField
    }()
    private lazy var destinationLocationField : UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 2
        textField.delegate = self
        textField.returnKeyType = .search
        textField.attributedPlaceholder = NSAttributedString(string: "Enter a Destination", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.5)])
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: textField.bounds.height))
        textField.textColor = UIColor.white
        textField.tintColor = UIColor.white
        textField.backgroundColor = UIColor(white: 0, alpha: 0.4)
        return textField
    }()
    private var startLocationIndicatorView : UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    private var linkingView : UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    private var destinationIndicatorView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    //MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configueUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Selectors
    @objc func handleBackButtonTapped() {
        delegate?.handleBackButtonTapped(locationInputView: self)
    }
    
    
    //MARK: - API
    
    //MARK: - Helpers
    func configueUI() {
        backgroundColor = .blackUber
        let view = UIView()
        view.addSubview(backButton)
        view.addSubview(fillNameLabel)
        
        

        let stackView = UIStackView(arrangedSubviews: [startLocationIndicatorView,linkingView,destinationIndicatorView])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 5
        stackView.distribution = .fillProportionally
        
        

        
        
        let stackView2 = UIStackView(arrangedSubviews: [sourceLocationField,destinationLocationField])
        stackView2.axis = .vertical
        stackView2.alignment = .center
        stackView2.distribution = .fillEqually
        stackView2.spacing = 8
        
        
        let stackView3 = UIStackView(arrangedSubviews: [stackView,stackView2])
        stackView3.axis = .horizontal
        stackView3.distribution = .fillProportionally
        stackView3.alignment = .center
        stackView3.spacing = 8
        let stackView4 = UIStackView(arrangedSubviews: [view,stackView3])
        stackView4.axis = .vertical
        stackView4.alignment = .center
        stackView4.distribution = .fill
        stackView4.spacing = 8
        
        addSubview(stackView4)
        view.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView4.translatesAutoresizingMaskIntoConstraints = false
        stackView2.translatesAutoresizingMaskIntoConstraints = false
        stackView3.translatesAutoresizingMaskIntoConstraints = false
        destinationLocationField.translatesAutoresizingMaskIntoConstraints = false
        sourceLocationField.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        fillNameLabel.translatesAutoresizingMaskIntoConstraints = false
        destinationIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        startLocationIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        linkingView.translatesAutoresizingMaskIntoConstraints = false
        let constraint = linkingView.heightAnchor.constraint(equalToConstant: 10)
        constraint.priority -= 1
        NSLayoutConstraint.activate([
            stackView4.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            stackView4.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -40),
            stackView4.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView4.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stackView3.widthAnchor.constraint(equalTo: stackView4.widthAnchor,multiplier: 0.95),
            fillNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            fillNameLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            backButton.topAnchor.constraint(equalTo: view.topAnchor),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),

            view.widthAnchor.constraint(equalTo: stackView4.widthAnchor),
            view.heightAnchor.constraint(equalTo: backButton.heightAnchor),
            destinationLocationField.widthAnchor.constraint(equalTo: stackView2.widthAnchor),
            sourceLocationField.widthAnchor.constraint(equalTo: stackView2.widthAnchor),
            destinationLocationField.heightAnchor.constraint(equalToConstant: 40),
            sourceLocationField.heightAnchor.constraint(equalToConstant: 40),
            
            constraint,
            stackView.heightAnchor.constraint(equalTo: stackView2.heightAnchor, multiplier: 0.5,constant: 12),
            linkingView.widthAnchor.constraint(equalToConstant: 3),
            startLocationIndicatorView.widthAnchor.constraint(equalToConstant: 10),
            startLocationIndicatorView.heightAnchor.constraint(equalToConstant: 10),
            destinationIndicatorView.heightAnchor.constraint(equalToConstant: 10),
            destinationIndicatorView.widthAnchor.constraint(equalToConstant: 10),
        ])
        setNeedsLayout()
        startLocationIndicatorView.layer.cornerRadius = 5
        destinationIndicatorView.layer.cornerRadius = 5
        linkingView.layer.cornerRadius = 1.5
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMinXMaxYCorner]
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 3
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        layer.shadowOpacity = 0.8
    }
    
    func configue() {
        guard let user = user else { return }
       let viewModel = LocationInputViewModel(inputView: self, user: user)
        viewModel.configueUI()
    }
}

extension LocationInputView : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.handleSearchLocation(location: textField.text, locationInputView: self)
        textField.resignFirstResponder()
        return true
    }
}
