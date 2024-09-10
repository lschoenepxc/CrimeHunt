//
//  BeaconVC.swift
//  Universe Hunt
//
//  Created by Laura Schöne on 18.07.24.
//

import UIKit

class BeaconVC: MainVC {
    
    @IBOutlet weak var lowRange: UILabel!
    @IBOutlet weak var mediumRange: UILabel!
    @IBOutlet weak var nearRange: UILabel!
    
    
    @IBOutlet weak var pageControlBeacon: UIPageControl!
    @IBOutlet weak var scrollViewBeacon: UIScrollView!
    
    var fullscreen = false
    
    // default for number of Pages for Places of Beacons
    var numberOfPages = 3
    
    var pages = [UIImageView()]
    
    // MARK: - Properties
    // Beacon
    private var beaconManager: BeaconManager! // Model for specialized tasks
    var isScanning = false // Boolean flag indicating which process we're currently in
    var beaconRanges = [0, 0, 0] // Keeps track of each beacons (3) ranges (immediate, near, far)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        numberOfPages = orte!.count
        
        lowRange.layer.masksToBounds = true
        mediumRange.layer.masksToBounds = true
        nearRange.layer.masksToBounds = true
        lowRange.layer.cornerRadius = 5
        mediumRange.layer.cornerRadius = 5
        nearRange.layer.cornerRadius = 5
        
        // 1.) scrollView
        scrollViewBeacon.minimumZoomScale=1
        scrollViewBeacon.maximumZoomScale=2
        scrollViewBeacon.bounces=false
        scrollViewBeacon.delegate = self // ViewController should take care if user scrolls (delegation)
        setupScrollView() // once at startup: setup content (better programmatically)
        // 2.) pageControl
        // pageControlBeacon.numberOfPages = 3  // number of pages
        // the following line does add an action programmatically
        pageControlBeacon.numberOfPages = numberOfPages  // number of pages
        // the following line does add an action programmatically
        pageControlBeacon.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)
        
        beaconManager = BeaconManager(
            beaconUUID: UUID(uuidString: "ACFD065E-C3C0-11E3-9BBE-1A514932AC01")!, // equal for all 3
            major: 1,
            // minor: UInt16 = 25090 // S/N 01/025090 (1)
            // minor: UInt16 = 21788 // S/N 01/021788 (2)
            // minor: UInt16 = 21788 // S/N 01/025088 (3)
            minorArray: [25090, 21788, 25088], // differentiate via minor value
            identifier: "de.th-owl.fb2.id_beacon" // we might need to distinguish
        )
        
        beaconManager.delegate = self
    }
    

    @IBAction func quizButton(_ sender: UIButton) {
        print("Pressed Rätsel Button")
        presentedQuizNo = 1
        self.parent?.performSegue(withIdentifier: "questionButtonSegue", sender: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func setupScrollView() {
        // let numberOfPages = 3  // amount of content inside the scrollView = pageControl !
        let numberOfPagesScroll = numberOfPages  // amount of content inside the scrollView = pageControl !
        for i in 0..<numberOfPagesScroll {
            let page = UIImageView()
            // let number = i + 1 // because i starts with 0
            // page.image = UIImage(named: "Explanation\(number)") // images in assets e.g. Explanation1
            // set placeholder image
            // page.image = UIImage(named: orte![i].picture) // images in assets for the places of the beacons (randomized)
            page.image = UIImage(named: "placeholder")
            
            // 4 values x/y: top corner left (origin) | width | height)
            // width & height equal scrollView
            page.frame = CGRect(x: CGFloat(i) * scrollViewBeacon.frame.size.width, y: 0, width: scrollViewBeacon.frame.size.width, height: scrollViewBeacon.frame.size.height)
            page.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(fullscreenImage))
            page.addGestureRecognizer(tap)
            // let labelPlaceName = UILabel()
            let labelPlaceName = VerticalAlignedLabel()
            labelPlaceName.textColor = .black
            //labelPlaceName.textAlignment = .center
            labelPlaceName.contentMode = .bottom
            labelPlaceName.font = .systemFont(ofSize: 20, weight: .medium)
            labelPlaceName.text = orte![i].name
            labelPlaceName.frame = page.bounds
            page.addSubview(labelPlaceName)
            pages.append(page)
            scrollViewBeacon.addSubview(page)
        }
        // we need to setup the ContentSize (3 pages side by side)
        scrollViewBeacon.contentSize = CGSize(width: scrollViewBeacon.frame.size.width * CGFloat(numberOfPages), height: scrollViewBeacon.frame.size.height)
        scrollViewBeacon.isPagingEnabled = true
    }
    
    @objc func fullscreenImage(_ sender: UITapGestureRecognizer) {
        if fullscreen {
            sender.view?.removeFromSuperview()
            fullscreen = false
        }
        else {
            let imageView = sender.view as! UIImageView
            let newImageView = UIImageView(image: imageView.image)
            newImageView.frame = UIScreen.main.bounds
            newImageView.backgroundColor = .black
            newImageView.contentMode = .scaleAspectFill
            newImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(fullscreenImage))
            newImageView.addGestureRecognizer(tap)
            self.view.addSubview(newImageView)
            fullscreen = true
        }
    }
    
    override func updateBeaconScrollView() {
        super.updateBeaconScrollView()
        print("override")
        for subview in scrollViewBeacon.subviews {
            if let label = subview as? UILabel {
                label.text = "Label aktualisiert"
            }
            if let imageView = subview as? UIImageView {
                imageView.image = UIImage(named: orte![currentIndex].picture)
            }
        }
    }
    
    // MARK: - UI Update Helper
    
    // change color regarding range of a specific beacon
    func updateBeaconView(beacon: Int, range: Int) {
        
        // switch between beacons, each beacon got 3 views for the ranges
        // print("range: \(range)") // 0 unknown | 1 immediate | 2 near | 3 far
        //let color: UIColor
        //switch range {
        //case 1: color = .red
        //case 2: color = .orange
        //case 3: color = .yellow
        //default: color = .black
        //}
        
        //if range > 0 {
         //   let rangeViewNumber = range - 1 // left immediate | middle near | right far
            //beaconViews![rangeViewNumber].backgroundColor = color
         //   beaconRanges[beacon] = range // keep track which range has been solved so far
            // keep track of the button here
            //beaconViews![rangeViewNumber].button.isHidden = false
       // }
    }
}

extension BeaconVC: UIScrollViewDelegate {
    
    // this is a custom function to change scrollView if pageControl is tapped
    @objc func pageControlTapped(_ sender: UIPageControl) {
        let page: Int = sender.currentPage
        var frame: CGRect = scrollViewBeacon.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        scrollViewBeacon.scrollRectToVisible(frame, animated: true)
    }
    
    // main function of UIScrollViewDelegate which takes care of user action
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // change page indicator dot to page visible (always just math! with scrollView)
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        pageControlBeacon.currentPage = Int(pageIndex)
    }
    
}

// MARK: - BeaconManagerDelegate

extension BeaconVC: BeaconManagerDelegate {
    func displayAuthorizationStatus(isEnabled: Bool?) {
        // do this in HuntViewController
    }
    
    // MARK: Update Beacon Range
    
    // BeaconManager reports an update on beacon and/or range
    func didUpdateBeaconRange(beacon: Int, range: Int) {
        // We change the corresponding view
        updateBeaconView(beacon: beacon, range: range)
    }
}

