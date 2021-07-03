//
//  InputStack.swift
//  Twitter
//
//  Created by macbook-pro on 13/05/2020.
//

import UIKit

class InputStack : UIStackView {
    init(placeholder:String,image: UIImage,isSecure: Bool = false) {
        super.init(frame: .zero)
        configueUI(placeholder: placeholder, image: image, isSecure: isSecure)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func textFeild() -> UITextField? {
        var textFeild : UITextField?
        subviews.forEach({ v in
            while textFeild == nil {
                textFeild = v.getTextFeild()
            }
        })
        return textFeild
    }
    
    func configueUI(placeholder:String, image: UIImage, isSecure: Bool) {
        let textField = UITextField()
        textField.delegate = self
        textField.textColor = .white
        textField.tintColor = .white
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.5)])
        textField.isSecureTextEntry = isSecure
        textField.borderStyle = .none
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [imageView,textField])
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.alignment = .lastBaseline
        stackView.spacing = 10
        
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        axis = .vertical
        distribution = .equalSpacing
        spacing = 0
        addArrangedSubview(stackView)
        addArrangedSubview(view)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 30),
            imageView.heightAnchor.constraint(equalToConstant: 30),
            view.heightAnchor.constraint(equalToConstant: 1),
            view.widthAnchor.constraint(equalTo: widthAnchor)
        ])
        
        

    }
    
}

extension InputStack: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
       return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
}
