import UIKit
import Foundation

class InvestigationVC: UIViewController {
    
    
    @IBOutlet weak var scrollViewInvestigation: UIScrollView!
    @IBOutlet weak var pageControlInvestigation: UIPageControl!
    
    @IBOutlet weak var anklageButton: UIButton!
    
    
    @IBOutlet weak var InvestigationSegmentedControl: UISegmentedControl!
    
    var akte: Akte?
    
    var verdaechtigeExclude = [false, false, false, false, false]
    var tatwaffenExclude = [false, false, false, false, false]
    var tatorteExclude = [false, false, false, false, false]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let akte = ladeAkteAusPlist() {
            //print("Verdächtige: \(akte.verdaechtige[0].name)")
            //print("Tatwaffen: \(akte.tatwaffen[0].bezeichnung)")
            //print("Tatorte: \(akte.tatorte[0].ort)")
            self.akte = akte
        } else {
            fatalError("Could NOT load Content Dictionary!")
        }
        
        anklageButton.layer.name = "Anklage"
        //anklageButton.isEnabled = false
        
        // selected option color
        InvestigationSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)

        // color of other options
        InvestigationSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        
        // 1.) scrollView
        scrollViewInvestigation.delegate = self // ViewController should take care if user scrolls (delegation)
        //setupScrollView() // once at startup: setup content (better programmatically)
        // Initial setup for suspects (index 0)
        setupScrollView(for: 0)
        // 2.) pageControl
        pageControlInvestigation.numberOfPages = 5  // number of pages
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
    
    func setupScrollView(for selectedSegmentIndex: Int) {
        // Remove any previous views from the scrollView
        scrollViewInvestigation.subviews.forEach { $0.removeFromSuperview() }
        
        var numberOfPages = 0
        var data: [Any] = []
        
        // Choose data source based on the selected segment
        switch selectedSegmentIndex {
        case 0: // Verdächtige
            numberOfPages = akte?.verdaechtige.count ?? 0
            data = akte?.verdaechtige ?? []
        case 1: // Tatwaffen
            numberOfPages = akte?.tatwaffen.count ?? 0
            data = akte?.tatwaffen ?? []
        case 2: // Tatorte
            numberOfPages = akte?.tatorte.count ?? 0
            data = akte?.tatorte ?? []
        default:
            break
        }
        
        // Build scrollView pages based on the selected data source
        for i in 0..<numberOfPages {
            // Container für jedes Element
            let pageView = UIView()
            // Abgerundete Ecken für die Seite
            pageView.layer.cornerRadius = 20.0
            pageView.layer.masksToBounds = true
            pageView.frame = CGRect(x: CGFloat(i) * scrollViewInvestigation.frame.size.width, y: 0, width: scrollViewInvestigation.frame.size.width, height: scrollViewInvestigation.frame.size.height)
            pageView.backgroundColor = .darkGray
                    
            // Bild
            let imageView = UIImageView()
            
            // Info-Button (oben rechts)
            let infoButton = UIButton(type: .infoLight)
            infoButton.frame = CGRect(x: scrollViewInvestigation.frame.size.width - 40, y: 10, width: 30, height: 30)
            
            // Titel-Label
            let titleLabel = UILabel()
            
            // Beschreibung-Label
            let descriptionLabel = UILabel()
            
            // Ausschließen-Button
            let excludeButton = UIButton(type: .system)
            excludeButton.accessibilityIdentifier = "ExcludeButton"
            
            // Handle different data types
            if let verdaechtiger = data[i] as? Verdaechtiger {
                imageView.image = UIImage(named: verdaechtiger.pic)
                pageView.layer.name = verdaechtiger.name
                titleLabel.text = verdaechtiger.name + " | " + verdaechtiger.job
                descriptionLabel.text = "Mordmotiv - " + verdaechtiger.motiv
                infoButton.layer.name = "verdaechtiger"
                excludeButton.layer.name = "verdaechtiger"
            } else if let tatwaffe = data[i] as? Tatwaffe {
                imageView.image = UIImage(named: tatwaffe.pic) // Assuming an image with weapon name exists
                pageView.layer.name = tatwaffe.bezeichnung
                titleLabel.text = tatwaffe.bezeichnung
                descriptionLabel.text = "Mordmethode - " + tatwaffe.methode
                infoButton.layer.name = "tatwaffe"
                excludeButton.layer.name = "tatwaffe"
            } else if let tatort = data[i] as? Tatort {
                imageView.image = UIImage(named: tatort.pic) // Assuming an image with location name exists
                pageView.layer.name = tatort.ort
                titleLabel.text = tatort.ort
                descriptionLabel.text = tatort.beschreibung
                infoButton.layer.name = "tatort"
                excludeButton.layer.name = "tatort"
            }
            
            imageView.frame = CGRect(x: 20, y: 20, width: scrollViewInvestigation.frame.size.width - 40, height: 200)
            imageView.contentMode = .scaleAspectFit
            pageView.addSubview(imageView)
            
            infoButton.tag = i
            infoButton.addTarget(self, action: #selector(infoButtonTapped(_:)), for: .touchUpInside)
            pageView.addSubview(infoButton)
            
            titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            titleLabel.textColor = .white
            titleLabel.frame = CGRect(x: 20, y: imageView.frame.maxY + 10, width: scrollViewInvestigation.frame.size.width - 40, height: 25)
            pageView.addSubview(titleLabel)
            
            descriptionLabel.font = UIFont.systemFont(ofSize: 14)
            descriptionLabel.textColor = .lightGray
            descriptionLabel.frame = CGRect(x: 20, y: titleLabel.frame.maxY + 5, width: scrollViewInvestigation.frame.size.width - 40, height: 20)
            pageView.addSubview(descriptionLabel)
            
            excludeButton.setTitle("Ausschließen", for: .normal)
            excludeButton.backgroundColor = .red
            excludeButton.setTitleColor(.white, for: .normal)
            excludeButton.frame = CGRect(x: 20, y: descriptionLabel.frame.maxY + 10, width: scrollViewInvestigation.frame.size.width - 40, height: 50)
            excludeButton.layer.cornerRadius = 10
            excludeButton.tag = i
            excludeButton.addTarget(self, action: #selector(excludeButtonTapped(_:)), for: .touchUpInside)
                    pageView.addSubview(excludeButton)
            
            // Füge den kompletten Container zur ScrollView hinzu
            scrollViewInvestigation.addSubview(pageView)
        }
        
        // Set content size of the scrollView based on number of pages
        scrollViewInvestigation.contentSize = CGSize(width: scrollViewInvestigation.frame.size.width * CGFloat(numberOfPages), height: scrollViewInvestigation.frame.size.height)
        scrollViewInvestigation.isPagingEnabled = true
    }
    
    @objc func infoButtonTapped(_ sender: UIButton) {
        let pageIndex = sender.tag  // Hier erhältst du die Seitenzahl/Index
        // (sender.layer.name ?? "No layer name")
        var title = ""
        var message = ""
        switch sender.layer.name {
        case "verdaechtiger":
            let info = akte?.verdaechtige[pageIndex]  // Hole die relevante Info basierend auf der Seitenzahl
            //print("Info-Button auf Seite \(pageIndex) wurde gedrückt. Verdächtiger: \(info?.info ?? "Unbekannt")")
            title = info!.name
            message = info!.info
        case "tatwaffe":
            let info = akte?.tatwaffen[pageIndex]  // Hole die relevante Info basierend auf der Seitenzahl
            //print("Info-Button auf Seite \(pageIndex) wurde gedrückt. Tatwaffe: \(info?.info ?? "Unbekannt")")
            title = info!.bezeichnung
            message = info!.info
        case "tatort":
            let info = akte?.tatorte[pageIndex]  // Hole die relevante Info basierend auf der Seitenzahl
            //print("Info-Button auf Seite \(pageIndex) wurde gedrückt. Tatort: \(info?.info ?? "Unbekannt")")
            title = info!.ort
            message = info!.info
        default:
            print("default")
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    @objc func excludeButtonTapped(_ sender: UIButton) {
        let pageIndex = sender.tag
        let category = sender.layer.name
        print("Ausschließen-Button gedrückt auf Seite \(pageIndex) im Segment \(String(describing: category))")
        
        // flag to check if already excluded
        var flag = false
        var pic = ""
        
        switch category {
        case "verdaechtiger":
            flag = verdaechtigeExclude[pageIndex]
            verdaechtigeExclude[pageIndex] = !verdaechtigeExclude[pageIndex]
            pic = akte!.verdaechtige[pageIndex].pic
        case "tatwaffe":
            flag = tatwaffenExclude[pageIndex]
            tatwaffenExclude[pageIndex] = !tatwaffenExclude[pageIndex]
            pic = akte!.tatwaffen[pageIndex].pic
        case "tatort":
            flag = tatorteExclude[pageIndex]
            tatorteExclude[pageIndex] = !tatorteExclude[pageIndex]
            pic = akte!.tatorte[pageIndex].pic
        default:
            print()
        }
        
        print("Vorher schon excluded: ", flag)
        
        // vorher excluded --> jetzt wieder included
        if flag {
            // Finde die Seite in der ScrollView
            let pageWidth = scrollViewInvestigation.frame.size.width
            let pageX = CGFloat(pageIndex) * pageWidth

            // Durchsuche die Subviews der aktuellen Seite
            for subview in scrollViewInvestigation.subviews {
                if subview.frame.origin.x == pageX {  // Überprüfe, ob wir auf der richtigen Seite sind
                    // Suche nach einem UIImageView in der Seite
                    for innerSubview in subview.subviews {
                        if let imageView = innerSubview as? UIImageView{
                            // Setze das originale Bild in das UIImageView
                            imageView.image = UIImage(named: pic)
                        }
                        
                        if let excludeButton = innerSubview as? UIButton, excludeButton.accessibilityIdentifier == "ExcludeButton" {
                            // Dieser Button ist der Exclude-Button (nicht der Info-Button)
                            excludeButton.setTitle("Ausschließen", for: .normal)
                        }
                    }
                }
            }
        }
        // vorher nicht excluded --> Verpixel das Bild
        else {
            // Finde die Seite in der ScrollView
            let pageWidth = scrollViewInvestigation.frame.size.width
            let pageX = CGFloat(pageIndex) * pageWidth

            // Durchsuche die Subviews der aktuellen Seite
            for subview in scrollViewInvestigation.subviews {
                if subview.frame.origin.x == pageX {  // Überprüfe, ob wir auf der richtigen Seite sind
                    // Suche nach einem UIImageView in der Seite
                    for innerSubview in subview.subviews {
                        if let imageView = innerSubview as? UIImageView,
                           let originalImage = imageView.image {
                            // Verpixel das Bild
                            let pixelatedImage = pixelateImage(image: originalImage)
                            // Setze das verpixelte Bild in das UIImageView
                            imageView.image = pixelatedImage
                        }
                        
                        if let excludeButton = innerSubview as? UIButton, excludeButton.accessibilityIdentifier == "ExcludeButton" {
                            // Dieser Button ist der Exclude-Button (nicht der Info-Button)
                            excludeButton.setTitle("Verdächtigen", for: .normal)
                        }
                    }
                }
            }
        }
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
    
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        // Reload the scrollView with the selected segment
        setupScrollView(for: sender.selectedSegmentIndex)
    }
    
    // Loading data from Data.plist file
    func ladeAkteAusPlist() -> Akte? {
        // 1. Pfad zur plist-Datei ermitteln
        if let path = Bundle.main.path(forResource: "Akte", ofType: "plist"),
           let xml = FileManager.default.contents(atPath: path) {
            do {
                // 2. Plist-Daten deserialisieren
                let plistData = try PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil) as? [String: Any]

                // Debug: Überprüfen, ob plistData geladen wurde
                // print("Plist-Daten: \(String(describing: plistData))")
                
                // 3. Verdächtige parsen
                let verdaechtigeArray = plistData?["Verdaechtige"] as? [[String: Any]] ?? []
                
                let verdaechtige = verdaechtigeArray.compactMap { dict -> Verdaechtiger? in
                    if let name = dict["name"] as? String,
                       let job = dict["job"] as? String,
                       let alter = dict["alter"] as? Int,
                       let motiv = dict["motiv"] as? String,
                       let info = dict["info"] as? String,
                       let pic = dict["pic"] as? String {
                        return Verdaechtiger(name: name, job: job, alter: alter, motiv: motiv, info: info, pic: pic)
                    }
                    return nil
                }

                // 4. Tatwaffen parsen
                let tatwaffenArray = plistData?["Tatwaffen"] as? [[String: Any]] ?? []
                let tatwaffen = tatwaffenArray.compactMap { dict -> Tatwaffe? in
                    if let bezeichnung = dict["bezeichnung"] as? String,
                       let methode = dict["methode"] as? String,
                       let info = dict["info"] as? String,
                       let pic = dict["pic"] as? String{
                        return Tatwaffe(bezeichnung: bezeichnung, methode: methode, info: info, pic: pic)
                    }
                    return nil
                }

                // 5. Tatorte parsen
                let tatorteArray = plistData?["Tatorte"] as? [[String: Any]] ?? []
                let tatorte = tatorteArray.compactMap { dict -> Tatort? in
                    if let ort = dict["ort"] as? String,
                       let beschreibung = dict["beschreibung"] as? String,
                       let info = dict["info"] as? String,
                       let pic = dict["pic"] as? String{
                        return Tatort(ort: ort, beschreibung: beschreibung, info: info, pic: pic)
                    }
                    return nil
                }

                // 6. Akte erstellen und zurückgeben
                return Akte(verdaechtige: verdaechtige, tatwaffen: tatwaffen, tatorte: tatorte)
                
            } catch {
                print("Fehler beim Laden der plist: \(error)")
            }
        }
        return nil
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

