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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        pageControlBeacon.numberOfPages = 3  // number of pages
        // the following line does add an action programmatically
        pageControlBeacon.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)
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
        let numberOfPages = 3  // amount of content inside the scrollView = pageControl !
        for i in 0..<numberOfPages {
            let page = UIImageView()
            let number = i + 1 // because i starts with 0
            page.image = UIImage(named: "Explanation\(number)") // images in assets e.g. Explanation1
            
            // 4 values x/y: top corner left (origin) | width | height)
            // width & height equal scrollView
            page.frame = CGRect(x: CGFloat(i) * scrollViewBeacon.frame.size.width, y: 0, width: scrollViewBeacon.frame.size.width, height: scrollViewBeacon.frame.size.height)
            page.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(fullscreenImage))
            page.addGestureRecognizer(tap)
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
