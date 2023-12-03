//
//  GridyCollectionViewController.swift
//  MapKitTutorial
//
//  Created by Zohar Mosseri on 02/12/2023.
//

import UIKit

//todo custom event with a name and age of the hostage as a subtitle
private let reuseIdentifier = "HostageCell"

class GridyCollectionViewController: UICollectionViewController {
    
    var startDate: Date!
    var timer: Timer?
    
    //@IBOutlet weak var timerLabel: UILabel!
    //@IBOutlet var logo: UIImageView!
    //@IBOutlet var hostageCell: HostageCell!
    
    
    
    private let hostageCell : HostageCell = {
        let cell = HostageCell()
        return cell
    }()
    
    var hostages = [Hostage]()
    
    
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
    
    private let logo : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "BringThemHomeNow")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startDate = Date(timeIntervalSince1970: 1696651200) // October 7th, 2023, 10 AM in seconds
        startTimer()
        
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (view.width/3) - 3, height: (view.width/3) - 3)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        
        
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        //view.addSubview(collectionView)

        
        
        view.addSubview(scrollView)
        scrollView.addSubview(logo)
        scrollView.addSubview(timerLabel)
        scrollView.addSubview(collectionView)
        
        hostages = [Hostage(imageName: "dani", name: "Shiri Bibas", age: 27, details: "shiri was abducted with her kids")]
        // Register cell classes
        collectionView.register(HostageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
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
        
        logo.frame = CGRect(x: 30, y: 50, width: scrollView.width-60, height: 50)
        timerLabel.frame = CGRect(x: 30, y: logo.bottom + 10, width: scrollView.width-30, height: 32)
        collectionView.frame = CGRect(x: 30, y: timerLabel.bottom + 10, width: scrollView.width-60, height: 500)
    }

    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hostages.count
    }


    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HostageCell", for: indexPath) as! HostageCell
        let hostage = hostages[indexPath.item]
        //cell.hostagePhoto.image = UIImage(named: hostage.imageName)
        //cell.nameAndAgeLabel.text = "\(hostage.name), \(hostage.age)"

        return cell
    }

    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let selectedHostage = hostages[indexPath.item]
        let detailsViewController = storyboard?.instantiateViewController(withIdentifier: "HostageDetailsViewController") as! HostageDetailsViewController
        detailsViewController.hostage = selectedHostage
        navigationController?.pushViewController(detailsViewController, animated: true)
    }



    /*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 100, height: 100)
    }
    */
    
    
    
    /*todo big check
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 200) // Adjust the height as needed
    }
     */

    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "GridyCollectionHeaderView", for: indexPath) as! GridyCollectionHeaderView

            
            timerLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            timerLabel.textColor = UIColor.systemRed
            
            logo.image = UIImage(named: "BringThemHomeNow")
            logo.contentMode = .scaleAspectFit

            return headerView
        }
        return UICollectionReusableView()
    }
    
}
