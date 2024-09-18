//
//  FinishViewController.swift
//  Universe Hunt
//
//  Created by Heizo Schulze on 27.06.24.
//

import UIKit
import MultipeerConnectivity

// MARK: - CloseDelegate Protocol

// Required to safely close a view controller itself and the VC which presented it as well
protocol CloseDelegate: AnyObject {
    func closeViewControllers()
}

class FinishViewController: UIViewController {
    
    // MARK: - UI Properties
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var sendResultButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    @IBOutlet weak var taeterButton: UIButton!
    
    @IBOutlet weak var tatwaffeButton: UIButton!
    
    @IBOutlet weak var tatortButton: UIButton!
    
    let taeterSource = ["Lara Fischer", "Marc Hofmann", "Jana Müller", "Timm Berger", "Erika Schmidt"]
    let tatwaffeSource = ["Fotostativ", "Gift", "Ladekabel", "Buchband", "Trophäe"]
    let tatortSource = ["Büro", "Videostudio", "Computerlabor", "Regieraum", "Besprechungsraum"]
    
    var anklage = ["Lara Fischer", "Fotostativ", "Büro"]
    let correctAnklage = ["Timm Berger", "Fotostativ", "Regieraum"]
    
    var anklageScore = 0
    
    weak var delegate: CloseDelegate?
    
    // MARK: - Properties
    
    // BLE Communication via Multipeer Connectivity Framework
    var mpcManager: MPCManager?
    
    var timeText = "-"
    var seconds = 0
    var score = 0
    var gameMessage: GameMessage?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        mpcManager = MPCManager() // initialize the manager
        mpcManager?.delegate = self // tell him whom to report to
        sendResultButton.isEnabled = false

        // add Dropdown for Taeter
        var menuChildrenTaeter: [UIMenuElement] = []
        for taeter in taeterSource {
            let action = createAction(title: taeter, category: "taeter")
            menuChildrenTaeter.append(action)
        }
            
        taeterButton.menu = UIMenu(options: .displayInline, children: menuChildrenTaeter)
            
        taeterButton.showsMenuAsPrimaryAction = true
        taeterButton.changesSelectionAsPrimaryAction = true
        
        // add Dropdown for Tatwaffe
        var menuChildrenTatwaffe: [UIMenuElement] = []
        for tatwaffe in tatwaffeSource {
            let action = createAction(title: tatwaffe, category: "tatwaffe")
            menuChildrenTatwaffe.append(action)
        }
            
        tatwaffeButton.menu = UIMenu(options: .displayInline, children: menuChildrenTatwaffe)
            
        tatwaffeButton.showsMenuAsPrimaryAction = true
        tatwaffeButton.changesSelectionAsPrimaryAction = true
        
        // add Dropdown for Tatort
        var menuChildrenTatort: [UIMenuElement] = []
        for tatort in tatortSource {
            let action = createAction(title: tatort, category: "tatort")
            menuChildrenTatort.append(action)
        }
            
        tatortButton.menu = UIMenu(options: .displayInline, children: menuChildrenTatort)
            
        tatortButton.showsMenuAsPrimaryAction = true
        tatortButton.changesSelectionAsPrimaryAction = true
        
        calculateAnklageScore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // we update the label here - can be sure data is received
        timeLabel.text = timeText
        
        mpcManager?.startBrowsing() // tell the manager to scan for peers
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        // tell manager to stop scanning (before this VC will disappear)
        mpcManager?.stopBrowsing()
        super.viewWillAppear(animated)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let sendVC = segue.destination as? PhotoViewController {
            
            // MARK: Hand over Data to PhotoVC
            // we need to hand over Game data for Apple TV
            sendVC.receiveGameDataForWrapping(seconds: self.seconds, score: self.score)
            // 2.) full screen
            // We do not use fullscreen here, so the user might return
            // sendVC.modalPresentationStyle = .fullScreen
            
        }
    }
    
    func createAction(title: String, category: String) -> UIAction {
        return UIAction(title: title) { action in
            //print("Action triggered for: \(title)")
            //print("Extra Info: \(category)")
            
            switch category {
            case "taeter":
                self.anklage[0] = title
            case "tatwaffe":
                self.anklage[1] = title
            case "tatort":
                self.anklage[2] = title
            default:
                print()
            }
            //print(self.anklage)
            self.calculateAnklageScore()
        }
    }
    
    func calculateAnklageScore() {
        if (anklage == correctAnklage) {anklageScore = 40}
        else {
            anklageScore = 0
            for i in 0..<3 {
                if (anklage[i] == correctAnklage[i]) {
                    anklageScore += 10
                }
            }
        }
        //print(anklageScore)
    }
    
    // MARK: - User Action
    
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        // this viewController closes itself
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendResultPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "sendSegue", sender: nil)
    }
    
    // MARK: - Data Entry
    
    // MARK: raw data from HuntVC
    func receiveGameData(timeString: String, seconds: Int, score: Int) {
        
        print("FinishVC received GameData, time: \(timeString), score: \(score)")
        self.timeText = timeString // we use the string for simplicity, preventing calculating it again
        self.seconds = seconds
        self.score = score
    }
    
    // MARK: wrapped data from PhotoVC
    func receiveGameMessage(_ gameMessage: GameMessage) {
        
        print("FinishVC received Game: \(gameMessage)")
        self.gameMessage = gameMessage
        
        let confirmation = sendMessageToTV()
        print("Tried to send game to TV. Got confirmation: \(confirmation)")
        
        self.presentedViewController?.dismiss(animated: true)
        
        if confirmation.send {
            showAlert(title: "Data Send", message: confirmation.message, quit: true)
        } else {
            showAlert(title: "Failure", message: confirmation.message, quit: false)
        }
        
    }
    
    // MARK: - Apple TV Communication
    
    // we send a message to the Apple TV
    private func sendMessageToTV() -> (send: Bool, message: String) {
        
        guard let result = self.gameMessage else {
            return (send: false, message: "There has been trouble with your game data.")
        }
        
        do {
            try mpcManager?.send(name: result.teamName, value: result.score + anklageScore, time: result.seconds, image: result.image)
            return (send: true, message: "Your result has been send and should be visible soon.")
        } catch {
            return (send: false, message: "Result could not be send. Try again.")
        }
    }
    
    func update(_ status: Int) {
        
        switch status {
        case 1: // connected
            statusLabel.text = "✅ Status: Connected!"
            sendResultButton.isEnabled = true
        case 2: // connecting
            statusLabel.text = "🤝 Status: Connecting…"
            sendResultButton.isEnabled = false
        case 3: // not nonnected
            statusLabel.text = "❌ Status: Not connected."
            sendResultButton.isEnabled = false
        default: // unknown
            statusLabel.text = "💀 Status: Unknown."
            sendResultButton.isEnabled = false
        }
        
        if status != 1 {
            
            if isPresentingAnotherViewController() {
                self.presentedViewController?.dismiss(animated: true)
            }
        }
    }
    
    // MARK: - Helper
    
    func isPresentingAnotherViewController() -> Bool {
        return self.presentedViewController != nil
    }
    
    // MARK: Convenience Alert
    
    func showAlert(title: String, message: String, quit: Bool) {
        // Step 1: Create the alert controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // MARK: Quit Code
        // will be called whenever the alert button "Close" has been tapped
        
        if quit { // the data has been successfully transfered, return to start
            
            // Step 2: Add an action to the alert
            let okAction = UIAlertAction(title: "Close", style: .default) { _ in
                
                self.delegate?.closeViewControllers()
                  
//                print("Close button tapped. Return to StartVC.")
//                // dismiss this FinishVC
//                self.dismiss(animated: true)
//
//                // dismiss HuntVC as well
//                if let huntVC = self.presentingViewController as? HuntViewController {
//                    huntVC.stopHunt()
//                    huntVC.dismiss(animated: true)
//                }
            }
            alertController.addAction(okAction)
            
        } else {
            // Step 2: Add an action to the alert
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                // Action handler (optional)
                print("OK button tapped")
            }
            alertController.addAction(okAction)
        }
        
        // Optional: Add more actions if needed
        // let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        // alertController.addAction(cancelAction)
        
        // Step 3: Present the alert
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Delegates
// MARK: MPCManagerDelegate

extension FinishViewController: MPCManagerDelegate {
    func didChangeState(to state: MCSessionState, peerID: MCPeerID) {
        
        var status = 0
        
        switch state {
        case .connected:
            print("Connected to \(peerID.displayName)")
            status = 1
        case .connecting:
            print("Connecting to \(peerID.displayName)")
            status = 2
        case .notConnected:
            print("Not connected to \(peerID.displayName)")
            status = 3
        @unknown default:
            print("Unknown state: \(state)")
        }
        
        // MARK: Update UI (on main thread)
        // We are in an asynchronos thread: any attempts to alter UI MUST put on main thread
        DispatchQueue.main.async {
            self.update(status)
        }
    }
    
    // We do not use this, since we do not receive data from Apple TV. Required in protocol.
    func didReceiveData(_ data: Data, from peerID: MCPeerID) {
        // Handle received data
        print("Received data from \(peerID.displayName)")
    }
    
    // Implement other delegate methods as needed
}
