//
//  InvestigationVC.swift
//  Universe Hunt
//
//  Created by Laura Schöne on 25.07.24.
//

import UIKit

class InvestigationVC: UIViewController {
    
    
    @IBOutlet weak var scrollViewInvestigation: UIScrollView!
    @IBOutlet weak var pageControlInvestigation: UIPageControl!
    
    @IBOutlet weak var InvestigationSegmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // selected option color
        InvestigationSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)

        // color of other options
        InvestigationSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        
        // 1.) scrollView
        scrollViewInvestigation.delegate = self // ViewController should take care if user scrolls (delegation)
        setupScrollView() // once at startup: setup content (better programmatically)
        // 2.) pageControl
        pageControlInvestigation.numberOfPages = 3  // number of pages
        // the following line does add an action programmatically
        pageControlInvestigation.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)
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
            page.layer.name = "Explanation \(number)"
            page.backgroundColor = .darkGray
            page.image = UIImage(named: "Explanation\(number)") // images in assets e.g. Explanation1
            
            // 4 values x/y: top corner left (origin) | width | height)
            // width & height equal scrollView
            page.frame = CGRect(x: CGFloat(i) * scrollViewInvestigation.frame.size.width, y: 0, width: scrollViewInvestigation.frame.size.width, height: scrollViewInvestigation.frame.size.height)
            page.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(popupMessage))
            page.addGestureRecognizer(tap)
            scrollViewInvestigation.addSubview(page)
        }
        // we need to setup the ContentSize (3 pages side by side)
        scrollViewInvestigation.contentSize = CGSize(width: scrollViewInvestigation.frame.size.width * CGFloat(numberOfPages), height: scrollViewInvestigation.frame.size.height)
        scrollViewInvestigation.isPagingEnabled = true
    }
    
    @objc func popupMessage(_ sender: UITapGestureRecognizer) {
        // show popup Message
        let title = sender.view?.layer.name
        let alert = UIAlertController(title: title, message: "You clicked!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    @IBAction func indizienButtonPressed(_ sender: Any) {
        print("Pressed Indizien Button")
        self.parent?.performSegue(withIdentifier: "indizienSegue", sender: nil)
    }
    
    @IBAction func finishButtonClicked(_ sender: UIButton) {
        self.parent?.performSegue(withIdentifier: "finishSegue", sender: nil)
    }
    
}

extension InvestigationVC: UIScrollViewDelegate {
    
    // this is a custom function to change scrollView if pageControl is tapped
    @objc func pageControlTapped(_ sender: UIPageControl) {
        let page: Int = sender.currentPage
        var frame: CGRect = scrollViewInvestigation.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        scrollViewInvestigation.scrollRectToVisible(frame, animated: true)
    }
    
    // main function of UIScrollViewDelegate which takes care of user action
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // change page indicator dot to page visible (always just math! with scrollView)
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        pageControlInvestigation.currentPage = Int(pageIndex)
    }
    
}

