//
//  RegisterViewController.swift
//  Twitter
//
//  Created by macbook-pro on 13/05/2020.
//

import UIKit

class RegisterViewController: UIViewController {
    let locationHandler = LocationHandler.shared


    //MARK: - Properties
    var mainStack : UIStackView!
    private let avatarButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(handleAddAvatar), for: .touchUpInside)
        return button
    }()
    private var profileImage : UIImage? {
        guard avatarButton.image(for: .normal) != #imageLiteral(resourceName: "plus_photo") else {
            return nil
        }
        return avatarButton.image(for: .normal)
    }
    private lazy var emailView: InputStack = {
        let image = UIImage(named: "ic_mail_outline_white_2x-1")!
        let iv = InputStack(placeholder: "Email", image: image)
        let textFeild = iv.textFeild()!
        textFeild.keyboardType = .emailAddress
        textFeild.clearButtonMode = .whileEditing

        return iv
    }()
    private lazy var segmentControl: UISegmentedControl = {
        let segment = UISegmentedControl(items: [UserOption.rider.description, UserOption.driver.description])
        segment.backgroundColor = .clear
        segment.layer.borderColor = UIColor.white.cgColor
        segment.layer.borderWidth = 1
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white,
                                        .font:UIFont.systemFont(ofSize: 18)], for: .normal)
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.black,
                                        .font: UIFont.systemFont(ofSize: 18)], for: .selected)
        segment.apportionsSegmentWidthsByContent = true
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(handleSeletedUser), for: .valueChanged)
        return segment
    }()
    private lazy var passwordView: InputStack = {
        let image = UIImage(named: "ic_lock_outline_white_2x")!
        let iv = InputStack(placeholder: "Password", image: image, isSecure: true)
        let textFeild = iv.textFeild()!
        textFeild.clearButtonMode = .whileEditing
        
        return iv
    }()
    private let fullNameView: InputStack = {
        let image = UIImage(named: "ic_person_outline_white_2x")!
        let iv = InputStack(placeholder: "Full Name", image: image)
        return iv
    }()
    private let usernameView: InputStack = {
        let image = UIImage(named: "ic_person_outline_white_2x")!
        let iv = InputStack(placeholder: "Username", image: image)
        return iv
    }()
    private let signUpButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setTitle("Sign Up", for: .normal)
        button.layer.cornerRadius = 4
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .white
        button.setTitleColor(.blackUber, for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    private let dontHaveAccountButton: UIButton = {
        let button = Utilities.attributedButton("Already have an account? ", " Log In")
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var imagePicker : UIImagePickerController = { 
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        vc.delegate = self
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        // Do any additional setup after loading the view.
        
        
    }
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        .lightContent
//    }
    
    
    //MARK: - Selectors
    @objc func handleSignUp() {
        guard let email = emailView.textFeild()?.text else { return }
        guard let password = passwordView.textFeild()?.text else { return }
        guard let fullName = fullNameView.textFeild()?.text else { return }
        guard let username = usernameView.textFeild()?.text?.lowercased() else { return }
        guard let profileImage = profileImage else { return }
        guard let data = profileImage.jpegData(compressionQuality: 1) else { return }
        guard let userOption = UserOption(rawValue: segmentControl.selectedSegmentIndex) else { return }
        let userCredentials = AuthCredentials(email: email,
                                              password: password,
                                              fullName: fullName,
                                              username: username,
                                              userOption: userOption.rawValue,
                                              imageProfile: data)
        AuthService.shared.registerUser(userCredentials) { [ weak self] error in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.dismiss(animated: true, completion: nil)
        }

    }
    @objc func handleSeletedUser(segmentControl: UISegmentedControl) {
        print(segmentControl.selectedSegmentIndex)
        
    }
    @objc func handleAddAvatar() {
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
    
    
    @objc func handleShowLogin() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .blackUber
        let stackView = UIStackView(arrangedSubviews: [emailView,passwordView,fullNameView,usernameView,segmentControl,signUpButton])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        
        let mainStackView = UIStackView(arrangedSubviews: [avatarButton,stackView])
        mainStack = mainStackView
        mainStackView.axis = .vertical
        mainStackView.alignment = .center
        mainStackView.distribution = .fillProportionally
        mainStackView.spacing = 40
        
        view.addSubview(mainStackView)
        view.addSubview(dontHaveAccountButton)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        avatarButton.translatesAutoresizingMaskIntoConstraints = false
        emailView.translatesAutoresizingMaskIntoConstraints = false
        passwordView.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        dontHaveAccountButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatarButton.widthAnchor.constraint(equalToConstant: 150),
            avatarButton.heightAnchor.constraint(equalTo: avatarButton.widthAnchor),
            emailView.widthAnchor.constraint(equalTo: view.widthAnchor,multiplier: 0.75),
            passwordView.widthAnchor.constraint(equalTo: emailView.widthAnchor),
            fullNameView.widthAnchor.constraint(equalTo: emailView.widthAnchor),
            usernameView.widthAnchor.constraint(equalTo: emailView.widthAnchor),
            mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            signUpButton.heightAnchor.constraint(equalToConstant: 44),
            signUpButton.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
            dontHaveAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dontHaveAccountButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -20),
            segmentControl.widthAnchor.constraint(equalTo: emailView.widthAnchor),
        ])
    }
    
}
extension RegisterViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            avatarButton.setImage(selectedImage, for: .normal)
        } else if let selectedImage = info[.originalImage] as? UIImage {
            avatarButton.setImage(selectedImage, for: .normal)
        }
        avatarButton.layer.cornerRadius = avatarButton.bounds.width/2
        avatarButton.layer.masksToBounds = true
        avatarButton.layer.borderWidth = 3
        avatarButton.layer.borderColor = UIColor.white.cgColor
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
