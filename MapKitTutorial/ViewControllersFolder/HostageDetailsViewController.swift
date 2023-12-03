//
//  HostageDetailsViewController.swift
//  MapKitTutorial
//
//  Created by Zohar Mosseri on 02/12/2023.
//

import Foundation
import UIKit

class HostageDetailsViewController: UIViewController {
    var hostage: Hostage?
    
    
    private let scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "car")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let nameAndAgeLabel: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.layer.cornerRadius = 12
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.backgroundColor = .white
        textView.showsVerticalScrollIndicator = true
        textView.font = UIFont.boldSystemFont(ofSize: 18)
        return textView
    }()
    
    
    
    private let detailsTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.layer.cornerRadius = 12
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.backgroundColor = .white
        textView.showsVerticalScrollIndicator = true
        return textView
    }()
    
    
    private let joinButton : UIButton = {
        let button = UIButton()
        button.setTitle("JOIN", for: .normal)
        button.backgroundColor = .green
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight : .bold)
        //button.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let navigateButton : UIButton = {
        let button = UIButton()
        button.setTitle("Navigate", for: .normal)
        button.backgroundColor = .orange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight : .bold)
        //button.addTarget(self, action: #selector(getDirections), for: .touchUpInside)
        return button
    }()
    
    private let findPrintShopsButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .blue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight : .bold)
        //button.addTarget(self, action: #selector(findPrintShopsNearby), for: .touchUpInside)
        return button
    }()
    
    private let groupChatButton : UIButton = {
        let button = UIButton()
        button.setTitle("Group Chat", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight : .bold)
        //button.addTarget(self, action: #selector(groupChatButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadHostageDetails()
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(nameAndAgeLabel)
        scrollView.addSubview(detailsTextView)
        scrollView.addSubview(joinButton)
        scrollView.addSubview(navigateButton)
        scrollView.addSubview(findPrintShopsButton)
        scrollView.addSubview(groupChatButton)
        
        if let hostage = hostage {
            nameAndAgeLabel.text = hostage.name + ", " +  String(hostage.age)
            detailsTextView.text = "Address: \(hostage.details)"
        }
    }
    
    /*
     override func viewWillAppear(_ animated: Bool) {
     loadHostageDetails()
     }
     */
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        
        imageView.frame = CGRect(x: 30, y: 5, width: scrollView.width-60, height: 50)
        nameAndAgeLabel.frame = CGRect(x: 30, y: imageView.bottom + 10, width: scrollView.width-60, height: 32)
        detailsTextView.frame = CGRect(x: 30, y: nameAndAgeLabel.bottom + 10, width: scrollView.width-60, height: 32)
        
        joinButton.frame = CGRect(x: 30, y: detailsTextView.bottom+10, width: (scrollView.width-60)/2, height: 32)
        navigateButton.frame = CGRect(x: joinButton.right + 10, y: detailsTextView.bottom+10, width: (scrollView.width-60)/2, height: 32)
        findPrintShopsButton.frame = CGRect(x: 30, y: navigateButton.bottom+10, width: (scrollView.width-60)/2, height: 32)
        groupChatButton.frame = CGRect(x: findPrintShopsButton.right + 10, y: navigateButton.bottom+10, width: (scrollView.width-60)/2, height: 32)
    }
    
    
    func loadHostageDetails() {
        // Ensure hostage is not nil before using it
        guard let hostage = hostage else {
            return
        }
    }
    
    @IBAction func close(){
        return dismiss(animated: true)
    }
    
}
