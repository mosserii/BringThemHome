//
//  RegisterViewController.swift
//  MapKitTutorial
//
//  Created by Zohar Mosseri on 26/11/2023.
//

import Foundation
import UIKit
import MapKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    
    
    private let scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Image")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let firstNameField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "First Name..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let lastNameField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Last Name..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let emailField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let registerButton : UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.red, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight : .bold)
        return button
    }()
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Register"
        view.backgroundColor = .white        
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        
        
        emailField.delegate = self
        passwordField.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        
        //let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        
        imageView.frame = CGRect(x: (scrollView.width - size)/2, y: 20, width: size, height: size)
        firstNameField.frame = CGRect(x: 30, y: imageView.bottom + 15, width: scrollView.width-60, height: 32)
        lastNameField.frame = CGRect(x: 30, y: firstNameField.bottom + 30, width: scrollView.width-60, height: 32)
        emailField.frame = CGRect(x: 30, y: lastNameField.bottom + 30, width: scrollView.width-60, height: 32)
        passwordField.frame = CGRect(x: 30, y: emailField.bottom+30, width: scrollView.width-60, height: 32)
        registerButton.frame = CGRect(x: 30, y: passwordField.bottom+30, width: scrollView.width-60, height: 32)
    }
    
    @objc private func registerButtonTapped(){
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        
        guard let firstName = firstNameField.text, let lastName = lastNameField.text, let email = emailField.text, let password = passwordField.text,
              !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserRegisterError(message: "please enter all information to register")
                return
        }
        
        DatabaseManager.shared.userExists(with: email, completion: { [weak self] exist in
            guard let strongSelf = self else{
                return
            }
            guard !exist else{
                strongSelf.alertUserRegisterError(message: "email address is already in use")
                return
            }
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {authResult, error in
                guard let result = authResult, error == nil else{
                    print("Error creating user")
                    return
                }
                let newUser = User(firstName: firstName, lastName: lastName, email: email, events: [])
                DatabaseManager.shared.insertUser(with: newUser, completion: {success in
                    if !success{
                        return
                    }
                    UserDefaults.standard.set(newUser.id, forKey: "User ID")
                })
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
        })
        UserDefaults.standard.set(firstName + " " + lastName, forKey: "name")
        UserDefaults.standard.set(email, forKey: "email")
    }
    
    
    func alertUserRegisterError(message:String){
        let alert = UIAlertController(title: "whoops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}

extension RegisterViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField{
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField{
            registerButtonTapped()
        }
        return true
    }
}
