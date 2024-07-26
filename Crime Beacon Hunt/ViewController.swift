//
//  ViewController.swift
//  Universe Hunt
//
//  Created by Heizo Schulze on 20.06.24.
//

import UIKit

// MARK: - Main ViewController

class ViewController: UIViewController {
    
    // MARK: - UI Properties
    
    @IBOutlet weak var scrollView: UIScrollView! // UI element added
    @IBOutlet weak var pageControl: UIPageControl! // UI element added
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 1.) scrollView
        scrollView.delegate = self // ViewController should take care if user scrolls (delegation)
        setupScrollView() // once at startup: setup content (better programmatically)
        // 2.) pageControl
        pageControl.numberOfPages = 3  // number of pages
        // the following line does add an action programmatically
        pageControl.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)
    }
    
    // MARK: - Layout Setup
    
    func setupScrollView() {
        let numberOfPages = 3  // amount of content inside the scrollView = pageControl !
        for i in 0..<numberOfPages {
                        
            let page = UIImageView()
            let number = i + 1 // because i starts with 0
            page.image = UIImage(named: "Explanation\(number)") // images in assets e.g. Explanation1
            
            // 4 values x/y: top corner left (origin) | width | height)
            // width & height equal scrollView
            page.frame = CGRect(x: CGFloat(i) * scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            scrollView.addSubview(page)
        }
        // we need to setup the ContentSize (3 pages side by side)
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(numberOfPages), height: scrollView.frame.size.height)
        scrollView.isPagingEnabled = true
    }
    
    // MARK: - User Action
    
    @IBAction func startButtonPressed(_ sender: Any) {
        
        // opens HuntVC
        performSegue(withIdentifier: "startSegue", sender: nil)
    }
    
    // MARK: - Navigation (here required for full screen only)
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startSegue" {
            if let destinationVC = segue.destination as? HuntViewController {
                destinationVC.modalPresentationStyle = .fullScreen
            }
        }
    }
}

// MARK: - ScrollView Delegate (sync ScrollView and pageControl)

extension ViewController: UIScrollViewDelegate {
    
    // this is a custom function to change scrollView if pageControl is tapped
    @objc func pageControlTapped(_ sender: UIPageControl) {
        let page: Int = sender.currentPage
        var frame: CGRect = scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        scrollView.scrollRectToVisible(frame, animated: true)
    }
    
    // main function of UIScrollViewDelegate which takes care of user action
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // change page indicator dot to page visible (always just math! with scrollView)
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
}

