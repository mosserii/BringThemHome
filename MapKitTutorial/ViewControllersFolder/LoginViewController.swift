//
//  LoginViewController.swift
//  MapKitTutorial
//
//  Created by Zohar Mosseri on 26/11/2023.
//

import Foundation
import UIKit
import MapKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    
    
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
    
    private let loginButton : UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.red, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight : .bold)
        return button
    }()
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log In"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        
        emailField.delegate = self
        passwordField.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        
        imageView.frame = CGRect(x: (scrollView.width - size)/2, y: 20, width: size, height: size)
        emailField.frame = CGRect(x: 30, y: imageView.bottom + 15, width: scrollView.width-60, height: 32)
        passwordField.frame = CGRect(x: 30, y: emailField.bottom+30, width: scrollView.width-60, height: 32)
        loginButton.frame = CGRect(x: 30, y: passwordField.bottom+30, width: scrollView.width-60, height: 32)
    }
    
    
    @objc private func didTapRegister(){
        let RVC = RegisterViewController()
        RVC.title = "Create Account"
        navigationController?.pushViewController(RVC, animated: true)
    }
    
    @objc private func loginButtonTapped(){
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6 else {
                alertUserLoginError()
                return
        }
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: {[weak self] authResult, error in
            guard let strongSelf = self else{
                return
            }
            guard let result = authResult, error == nil else{
                print("Error logging in")
                return
            }
            let loggedInUser = result.user
            let safeEmail = DatabaseManager.makeSafeEmail(with: email)
            
            DatabaseManager.shared.getUserData(with: DatabaseManager.makeSafeEmail(with: email)) { (user) in
                if let user = user {
                    UserDefaults.standard.set(user.firstName + " " + user.lastName, forKey: "name")
                    UserDefaults.standard.set(user.id, forKey: "User ID")
                } else {
                    print("User not found")
                }
            }
            UserDefaults.standard.set(email, forKey: "email")
            
            
            
            print("logged in user:  \(loggedInUser)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        
    }
    
    func alertUserLoginError(){
        let alert = UIAlertController(title: "whoops", message: "please enter all information to log in", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

}

extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField{
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField{
            loginButtonTapped()
        }
        return true
    }
}
