//  LoginViewController.swift
//  islearn
//
//  Created by student-2 on 06/03/25. Logo Stencil

import UIKit

class LoginViewController: UIViewController {
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Logo Stencil"))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.boldSystemFont(ofSize: 28)
            let attributedText = NSMutableAttributedString(string: "Welcome To ")
            let iSLearnText = NSAttributedString(string: "iSLearn", attributes: [.foregroundColor: UIColor.accent])
            attributedText.append(iSLearnText)
            label.attributedText = attributedText
            label.textColor = .white
            label.textAlignment = .center
            return label
        }()
        
        private let authSegmentedControl: UISegmentedControl = {
            let segmentedControl = UISegmentedControl(items: ["Sign In", "Sign Up"])
            segmentedControl.selectedSegmentIndex = 0
            segmentedControl.selectedSegmentTintColor = .accent
            segmentedControl.backgroundColor = UIColor.systemGray5
            segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
            return segmentedControl
        }()
        
        private func createTextField(placeholder: String, isSecure: Bool = false) -> UITextField {
            let textField = UITextField()
            textField.placeholder = placeholder
            textField.isSecureTextEntry = isSecure
            textField.textColor = .white
            textField.font = UIFont.systemFont(ofSize: 16)
            
            // iOS-style rounded background
            textField.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
            textField.layer.cornerRadius = 12
            textField.layer.masksToBounds = true
            textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 40))
            textField.leftViewMode = .always
            
            return textField
        }
        
        private lazy var emailTextField = createTextField(placeholder: "Enter Email")
        private lazy var passwordTextField = createTextField(placeholder: "Enter Password", isSecure: true)
        private lazy var confirmPasswordTextField: UITextField = {
            let textField = createTextField(placeholder: "Confirm Password", isSecure: true)
            textField.isHidden = true // Initially hidden
            return textField
        }()
        
        private let authButton: UIButton = {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = .accent
            config.baseForegroundColor = .white
            config.cornerStyle = .medium
            config.title = "Log In"
            config.buttonSize = .large
            
            let button = UIButton(configuration: config)
            return button
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .black
            setupLayout()
            
            // Actions
            authButton.addTarget(self, action: #selector(authenticateUser), for: .touchUpInside)
            authSegmentedControl.addTarget(self, action: #selector(toggleAuthMode), for: .valueChanged)
            
            // Dismiss keyboard on tap
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(tapGesture)
        }
        
        private func setupLayout() {
            [logoImageView, titleLabel, authSegmentedControl, emailTextField, passwordTextField, confirmPasswordTextField, authButton].forEach {
                view.addSubview($0)
                $0.translatesAutoresizingMaskIntoConstraints = false
            }
            
            NSLayoutConstraint.activate([
                // Logo
                logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
                logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                logoImageView.widthAnchor.constraint(equalToConstant: 120),
                logoImageView.heightAnchor.constraint(equalToConstant: 120),
                
                // Title Label
                titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
                titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
                titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
                
                // Segmented Control
                authSegmentedControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
                authSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
                authSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
                authSegmentedControl.heightAnchor.constraint(equalToConstant: 44),
                
                // Email
                emailTextField.topAnchor.constraint(equalTo: authSegmentedControl.bottomAnchor, constant: 30),
                emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
                emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
                emailTextField.heightAnchor.constraint(equalToConstant: 50),
                
                // Password
                passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
                passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
                passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
                passwordTextField.heightAnchor.constraint(equalToConstant: 50),
                
                // Confirm Password
                confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
                confirmPasswordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
                confirmPasswordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
                confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
                
                // Auth Button
                authButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 40),
                authButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
                authButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
                authButton.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        
        @objc private func authenticateUser() {
            let tabVC = TabBarController()
            tabVC.modalPresentationStyle = .fullScreen
            present(tabVC, animated: true, completion: nil)
        }
        
        @objc private func toggleAuthMode() {
            let isSignUp = authSegmentedControl.selectedSegmentIndex == 1
            confirmPasswordTextField.isHidden = !isSignUp
            authButton.configuration?.title = isSignUp ? "Sign Up" : "Log In"
        }
        
        @objc private func dismissKeyboard() {
            view.endEditing(true)
        }
}
