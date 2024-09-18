import UIKit

class HuntViewController: MainVC {
    
    // MARK: - UI Properties
    
    //@IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var HuntSegmentedControl: UISegmentedControl!
    
    // MARK: - Properties
    // Beacon
    private var beaconManager: BeaconManager! // Model for specialized tasks
    var isScanning = false // Boolean flag indicating which process we're currently in
    //var beaconRanges = [0, 0, 0] // Keeps track of each beacons (3) ranges (immediate, near, far)
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // selected option color
        HuntSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)

        // color of other options
        HuntSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        
        // Do any additional setup after loading the view.
        // 1.) Our specialized model is created
        beaconManager = BeaconManager(
            beaconUUID: UUID(uuidString: "ACFD065E-C3C0-11E3-9BBE-1A514932AC01")!, // equal for all 3
            major: 1,
            // minor: UInt16 = 25090 // S/N 01/025090 (1)
            // minor: UInt16 = 21788 // S/N 01/021788 (2)
            // minor: UInt16 = 21788 // S/N 01/025088 (3)
            minorArray: minorArray, // differentiate via minor value
            identifier: "de.th-owl.fb2.id_beacon" // we might need to distinguish
        )
        beaconManager.delegate = self // Tell the manager whom to report
        
        // 3.) authorize and start
        beaconManager.displayAuthorizationStatus()
        startHunt()
    }
    
    // MARK: - Start/Stop
    
    func startHunt() {
        // prepare UI
        timecodeLabel.text = "00:00:00"
        // start
        startTimer()
        beaconManager.startScanning()
        isScanning = true
        
    }
    
    func stopHunt() {
        // stop
        stopTimer()
        beaconManager.stopScanning()
        isScanning = false
        currentIndex = 0
    }
    
    // MARK: - User Action
    
    // we need to stop without finishing the game
    @IBAction func stopButtonPressed(_ sender: Any) {
        
        stopHunt()
        print(currentIndex)
        
        // this viewController closes itself
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - BeaconManagerDelegate

extension HuntViewController: BeaconManagerDelegate {
    
    // MARK: Update Authorization Status
    
    // BeaconManager has an update on access
    func displayAuthorizationStatus(isEnabled: Bool?) {
        
        // We need to inform the user of the status of access
        //if let on = isEnabled {
            
            //if on {
                //statusLabel.text = "Location sharing enabled."
            //} else {
                //statusLabel.text = "Enable location sharing!"
                //print("NOT enabled")
            //}
            
        //} else { // not set, therefore unknown status
            //statusLabel.text = "Location sharing unclear!"
            //print("NOT set")
        //}
    }
    
    // MARK: Update Beacon Range
    
    // BeaconManager reports an update on beacon and/or range
    func didUpdateBeaconRange(beacon: Int, range: Int) {
        // We change the corresponding view
        // do the update in BeaconVC
        //updateBeaconView(beacon: beacon, range: range)
    }
}
