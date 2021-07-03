//
//  LoginViewController.swift
//  Twitter
//
//  Created by macbook-pro on 13/05/2020.
//

import UIKit

class LoginViewController: UIViewController {
    //MARK: - Properties
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "uber-logo")
        return iv
    }()
    
    private let emailView: InputStack = {
        let image = UIImage(named: "ic_mail_outline_white_2x-1")!
        let iv = InputStack(placeholder: "Email", image: image)
        return iv
    }()
    private let passwordView: InputStack = {
        let image = UIImage(named: "ic_lock_outline_white_2x")!
        let iv = InputStack(placeholder: "Password", image: image, isSecure: true)
        return iv
    }()
    private let loginButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setTitle("Log In", for: .normal)
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .white
        button.setTitleColor(.blackUber, for: .normal)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    private let dontHaveAccountButton: UIButton = {
        let button = Utilities.attributedButton("Don't have an account? ", " Sign Up")
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)

        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
    
    //MARK: - Selectors
    @objc func handleShowSignUp() {
        let register = RegisterViewController()
        show(register, sender: self)
    }
    @objc func handleLogin() {
        guard let email = emailView.textFeild()?.text  else { return }
        guard let password = passwordView.textFeild()?.text  else { return }
        AuthService.shared.logUserIn(email: email, password: password) { [weak self] _, error in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    //MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .blackUber
        let stackView = UIStackView(arrangedSubviews: [emailView,passwordView,loginButton])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        
        let mainStackView = UIStackView(arrangedSubviews: [logoImageView,stackView])
        mainStackView.axis = .vertical
        mainStackView.alignment = .center
        mainStackView.distribution = .fillProportionally
        mainStackView.spacing = 40
        
        view.addSubview(mainStackView)
        view.addSubview(dontHaveAccountButton)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        emailView.translatesAutoresizingMaskIntoConstraints = false
        passwordView.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        dontHaveAccountButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 150),
            logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor),
            emailView.widthAnchor.constraint(equalTo: view.widthAnchor,multiplier: 0.75),
            passwordView.widthAnchor.constraint(equalTo: emailView.widthAnchor),
            mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 44),
            loginButton.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
            dontHaveAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dontHaveAccountButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -20)
        ])
    }
    
}
extension UIViewController {
    var isPortrait : Bool {
        return view.window!.windowScene!.interfaceOrientation.isPortrait
    }
    var widthIsRegular : Bool {
        return traitCollection.horizontalSizeClass == .regular
    }
    var heightIsRegular : Bool {
        return traitCollection.verticalSizeClass == .regular
    }
    var IsDark : Bool {
        return traitCollection.userInterfaceStyle == .dark
    }
    var device : UIUserInterfaceStyle {
        return  traitCollection.userInterfaceStyle
    }
}
