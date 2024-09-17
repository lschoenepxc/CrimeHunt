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
    var labelTexts = [String]()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        labelTexts = []
        
        var text = """
        Willkommen Detektiv,
                    
        In der vergangenen Nacht wurde Professor Mats Klein, ein Dozent des Fachbereichs Medienproduktion, während der Dreharbeiten eines Filmprojekts auf dem Campus ermordet. Die Polizei ist ratlos und braucht nun deine Hilfe.
                    
        Wer hat Professor Klein getötet?
        Wo geschah es, und wie wurde er ermordet?
        """
        labelTexts.append(text)
        
        text = """
        Was ist zu tun?

        Als Detektiv musst du sechs versteckte Beacon auf dem Campus finden und die anschließend freigeschalteten Rätsel lösen. Durch das korrekte Lösen dieser Rätsel erhältst du die entscheidenden Indizien, mit denen du in der Akte den Täter, die Tatwaffe und den Tatort identifizieren kannst.

        Nur mit scharfem Verstand und einem klaren Plan wirst du es schaffen, den Mordfall zu lösen.
        """
        labelTexts.append(text)
        
        text = """
        Aber Vorsicht…

        das Lösen der Rätsel kann zwar beliebig oft versucht werden, doch jeder Fehlversuch verringert die zu erspielenden Punkte. Der Detektiv, der den Mordfall am schnellsten löst und dabei die meisten Punkte erzielt, wird als Sieger hervorgehen.
        Bringe also nun die Wahrheit ans Licht – die Gerechtigkeit liegt in deinen Händen!
        """
        labelTexts.append(text)
        
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
                        
            //let page = UIImageView()
            let number = i + 1 // because i starts with 0
            
            let label = UILabel()
            label.numberOfLines = 0  // Ermöglicht unbegrenzte Zeilen
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = .white
                    
            // 4. Text für das Label mit Zeilenumbrüchen
            label.text = labelTexts[i]
                    
            label.font = UIFont.systemFont(ofSize: 18)  // Schriftgröße setzen
            
            // Container View für jede Seite
            let pageView = UIView()
            pageView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(pageView)
            
            // Füge das Label zur Seite hinzu
            pageView.addSubview(label)
            
            // Auto Layout für jede Seite
            NSLayoutConstraint.activate([
                pageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                pageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                pageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
                pageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: CGFloat(i) * scrollView.frame.size.width),
                        
                // Label-Constraints innerhalb der Seite
                label.topAnchor.constraint(equalTo: pageView.topAnchor, constant: 20),
                label.leadingAnchor.constraint(equalTo: pageView.leadingAnchor, constant: 20),
                label.trailingAnchor.constraint(equalTo: pageView.trailingAnchor, constant: -20),
                label.bottomAnchor.constraint(lessThanOrEqualTo: pageView.bottomAnchor, constant: -20)
            ])
            
            // 4 values x/y: top corner left (origin) | width | height)
            // width & height equal scrollView
            //label.frame = CGRect(x: CGFloat(i) * scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            //scrollView.addSubview(label)
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

