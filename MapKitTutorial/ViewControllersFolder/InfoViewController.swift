//
//  InfoViewController.swift
//  MapKitTutorial
//
//  Created by Zohar Mosseri on 24/11/2023.
//

import Foundation
import UIKit


class InfoViewController : UIViewController {
    
    //@IBOutlet weak var timerLabel: UILabel!
    
    var startDate: Date!
    var timer: Timer?
    
    private let scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let timerLabel : UILabel = {
        let field = UILabel()
        field.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        field.textColor = UIColor.systemRed
        //field.backgroundColor = UIColor.black
        return field
    }()
    

    

    
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "BringThemHomeNow")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let infoLabel : UITextView = {
        let field = UITextView()
        field.text = "This app was created for helping to Bring Back Home our loved ones.\nCreated by Zohar Mosseri <3"
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.backgroundColor = .white
        return field
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startDate = Date(timeIntervalSince1970: 1696651200) // October 7th, 2023, 10 AM in seconds
        startTimer()
        
        
        
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(timerLabel)
        //scrollView.addSubview(gridyCollectionViewController)
        scrollView.addSubview(infoLabel)
        
    }
    
    func updateTimerLabel() {
        let currentDate = Date()
        let elapsedTime = currentDate.timeIntervalSince(startDate)
        
        let timeFormatter = DateComponentsFormatter()
        timeFormatter.unitsStyle = .full
        timeFormatter.allowedUnits = [.day, .hour, .minute, .second]
        
        if let formattedTime = timeFormatter.string(from: elapsedTime) {
            timerLabel.text = "Timer: \(formattedTime)"
        }
    }

    func startTimer() {
        // Update the timer label every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateTimerLabel()
        }
    }
    
    deinit {
            timer?.invalidate()
        }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        
        imageView.frame = CGRect(x: 30, y: -50, width: scrollView.width-60, height: 50)
        timerLabel.frame = CGRect(x: 30, y: imageView.bottom + 10, width: scrollView.width-30, height: 32)
        infoLabel.frame = CGRect(x: 30, y: timerLabel.bottom + 10, width: scrollView.width-60, height: 500)
    }
}
