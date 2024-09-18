//
//  BeaconManager.swift
//  Beacon Hunt
//
//  Created by Heizo Schulze on 21.05.24.
//

import CoreLocation

protocol BeaconManagerDelegate: AnyObject {
    func didUpdateBeaconRange(beacon: Int, range: Int)
    func displayAuthorizationStatus(isEnabled: Bool?)
}

// MARK: - Framework Core Location

class BeaconManager: NSObject, CLLocationManagerDelegate {
    
    // MARK: - Properties
    // MARK: Manager Class (Model)
    private var locationManager: CLLocationManager!
    // MARK: Beacon Identity Helper
    private var beaconUUID: UUID
    private var major: UInt16
    private var minorArray: [UInt16]
    private var identifier: String
    // MARK: Delegate (Controller) for reporting results
    weak var delegate: BeaconManagerDelegate?

    // MARK: - Life Cycle
    
    init(beaconUUID: UUID, major: UInt16, minorArray: [UInt16], identifier: String) {
        self.beaconUUID = beaconUUID
        self.major = major
        self.minorArray = minorArray
        self.identifier = identifier
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
    }

    func startScanning() {
        for minor in minorArray {
            let beaconIdentity = CLBeaconIdentityConstraint(uuid: beaconUUID, major: major, minor: minor)
            let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: beaconIdentity, identifier: identifier)
            locationManager.startMonitoring(for: beaconRegion)
            locationManager.startRangingBeacons(satisfying: beaconIdentity)
        }
    }

    func stopScanning() {
        for minor in minorArray {
            let beaconIdentity = CLBeaconIdentityConstraint(uuid: beaconUUID, major: major, minor: CLBeaconMinorValue(minor))
            locationManager.stopRangingBeacons(satisfying: beaconIdentity)
        }
    }

    // CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        for beacon in beacons {
            guard let minor = beacon.minor as? UInt16 else { continue }
            
            // production ready
            let beaconIndex = minorArray.firstIndex(of: minor) ?? -1
            // for testing with only one beacon use this
            // let beaconIndex = currentIndex
            if beaconIndex != -1 {
                delegate?.didUpdateBeaconRange(beacon: beaconIndex, range: beacon.proximity.rawValue)
            }
        }
    }
    
    // Can be be called automatically and from ViewController
    func displayAuthorizationStatus() {
        
        switch locationManager.authorizationStatus {
        case .restricted, .denied:
            delegate?.displayAuthorizationStatus(isEnabled: false)
        case .authorizedAlways, .authorizedWhenInUse:
            delegate?.displayAuthorizationStatus(isEnabled: true)
        default:
            delegate?.displayAuthorizationStatus(isEnabled: nil)
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // Handle authorization status change
        displayAuthorizationStatus()
    }
}
