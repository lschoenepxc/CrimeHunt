//
//  IndizienVC.swift
//  Universe Hunt
//
//  Created by Laura Schöne on 26.07.24.
//

import UIKit

class IndizienVC: MainVC {
    
    
    @IBOutlet weak var tableViewIndizien: UITableView!
    
    var ortIndizien = [[String]]()
    
    var orteNamen = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (currentIndex > 0) {
            let count = 0...currentIndex-1
            for index in count {
                orteNamen.append(orte![index].name)
                ortIndizien.append(orte![index].indizien)
                print(orteNamen)
            }
        }
        
        //for ort in orte! {
        //    orteNamen.append(ort.name)
        //    ortIndizien.append(ort.indizien)
        //}

        // Do any additional setup after loading the view.
        tableViewIndizien.delegate = self
        tableViewIndizien.dataSource = self
        
        // Erstelle den Balken-View
        let indicatorBar = UIView()
        indicatorBar.backgroundColor = UIColor.systemGray4
        indicatorBar.layer.cornerRadius = 2.5
            
        // Setze die Abmessungen des Balkens
        indicatorBar.translatesAutoresizingMaskIntoConstraints = false
        indicatorBar.heightAnchor.constraint(equalToConstant: 5).isActive = true
        indicatorBar.widthAnchor.constraint(equalToConstant: 80).isActive = true
            
        // Füge den Balken zum View Controller hinzu
        self.view.addSubview(indicatorBar)
            
        // Setze die Position in der Mitte des oberen Randes des View Controllers
        NSLayoutConstraint.activate([
            indicatorBar.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 8),
            indicatorBar.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        
        // Enable vertical scroll indicator
        tableViewIndizien.showsVerticalScrollIndicator = true
        // Optional: Customize scroll indicator color
        tableViewIndizien.indicatorStyle = .white

        // Dynamic cell height
        tableViewIndizien.rowHeight = UITableView.automaticDimension
        tableViewIndizien.estimatedRowHeight = 44
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Alert hier anzeigen
        if (currentIndex < 1) {
            let emptyMessageText = "Es sind noch keine Indizien freigespielt worden. Suche Beacons und löse Rätsel, um Indizien zu erhalten."
            let emptyMessageTitle = "Noch keine Indizien freigespielt"
            let emptyAlert = UIAlertController(title: emptyMessageTitle, message: emptyMessageText, preferredStyle: .alert)
            emptyAlert.addAction(UIAlertAction(title: "Verstanden", style: .cancel, handler: nil))
            present(emptyAlert, animated: true)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension IndizienVC : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return orteNamen.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ortIndizien[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = .black

        let sectionLabel = UILabel(frame: CGRect(x: 10, y: 0, width:
                    tableView.bounds.size.width, height: tableView.bounds.size.height))
        //sectionLabel.font = UIFont(name: "Helvetica", size: 12)
        sectionLabel.textColor = .lightGray
        sectionLabel.text = orteNamen[section]
        sectionLabel.sizeToFit()
        headerView.addSubview(sectionLabel)

        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewIndizien.dequeueReusableCell(withIdentifier: "indizienCell", for: indexPath)
        // Einstellungen für das Textlabel
        cell.textLabel?.numberOfLines = 0 // Erlaubt unbegrenzte Zeilen
        cell.textLabel?.lineBreakMode = .byWordWrapping // Zeilenumbruch erfolgt bei Wörtern
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .black
        cell.textLabel?.text = ortIndizien[indexPath.section][indexPath.row]
        return cell
    }
}

extension IndizienVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("You selected me!")
        //print(indexPath.row)
        //print(indexPath.section)
    }
}
