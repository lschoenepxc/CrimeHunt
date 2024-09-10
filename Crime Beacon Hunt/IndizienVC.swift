//
//  IndizienVC.swift
//  Universe Hunt
//
//  Created by Laura Schöne on 26.07.24.
//

import UIKit

class IndizienVC: UIViewController {
    
    
    @IBOutlet weak var tableViewIndizien: UITableView!
    
    let ort1 = [
        "Etwas1", "Etwas2", "Etwas3"
    ]
    let ort2 = [
        "Etwas1", "Etwas2", "Etwas3"
    ]
    let ort3 = [
        "Etwas1", "Etwas2", "Etwas3"
    ]
    
    let orteNamen = ["Küche", "WC", "Garten"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return ort1.count
        case 1:
            return ort2.count
        case 2:
            return ort3.count
        default:
            return 0
        }
    }
    
    //func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //    return orteNamen[section]
    //}
    
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
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .black
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = ort1[indexPath.row]
        case 1:
            cell.textLabel?.text = ort2[indexPath.row]
        case 2:
            cell.textLabel?.text = ort3[indexPath.row]
        default:
            cell.textLabel?.text = ""
        }
        return cell
    }
}

extension IndizienVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected me!")
        print(indexPath.row)
        print(indexPath.section)
    }
}
