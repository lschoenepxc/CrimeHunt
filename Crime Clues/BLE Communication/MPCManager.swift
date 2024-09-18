//
//  MPCManager.swift
//  MPCRevisited
//
//  Created by Gabriel Theodoropoulos on 11/1/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import MultipeerConnectivity

struct Message: Codable {
    
    let app: String // distinguish the data for showing all on one screen at AppleTV
    let user: String // name of person
    let score: Int // result of person
    let seconds: Int // time elapsed to finish game
    let imageData: Data // raw image of person
}

protocol MPCManagerDelegate: AnyObject {
    func didChangeState(to state: MCSessionState, peerID: MCPeerID)
    func didReceiveData(_ data: Data, from peerID: MCPeerID)
    // Add other delegate methods as needed
}

class MPCManager: NSObject {
    weak var delegate: MPCManagerDelegate?
    
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    var mcNearbyServiceAdvertiser: MCNearbyServiceAdvertiser!
    var mcNearbyServiceBrowser: MCNearbyServiceBrowser!
    
    var connectedPeer: MCPeerID?
    
    override init() {
        super.init()
        
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        
        mcNearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: Constants.serviceTypeName)
        mcNearbyServiceAdvertiser.delegate = self
        
        mcNearbyServiceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: Constants.serviceTypeName)
        mcNearbyServiceBrowser.delegate = self
    }
    
    func startBrowsing() {
        mcNearbyServiceBrowser.startBrowsingForPeers()
    }
    
    func startAdvertising() {
        mcNearbyServiceAdvertiser.startAdvertisingPeer()
    }
    
    func stopBrowsing() {
        mcNearbyServiceBrowser.stopBrowsingForPeers()
    }
    
    func stopAdvertising() {
        mcNearbyServiceAdvertiser.stopAdvertisingPeer()
    }
    
    // MARK: Send Message
    
    func send(name: String, value: Int, time: Int, image: UIImage) throws {
        // let imageAsData = image.pngData()!
        let imageAsData = image.jpegData(compressionQuality: 1.0)!
        
        // TODO: change this to your App name index
        let message = Message(app: Constants.appNames[0],
                              user: name,
                              score: value,
                              seconds: time,
                              imageData: imageAsData)
        
        let payload = try JSONEncoder().encode(message)
        
        guard let peer = connectedPeer else {
            debugPrint("Message NOT sent to peer!")
            return
        }
        
        try self.mcSession.send(payload, toPeers: [peer], with: .reliable)
    }
}

extension MPCManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found peer: \(peerID.displayName)")
        browser.invitePeer(peerID, to: mcSession, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID.displayName)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("MPCManager Browser could not start: \(error.localizedDescription)")
    }
}

extension MPCManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Received invitation from \(peerID.displayName)")
        invitationHandler(true, mcSession)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("MPCManager Advertiser could not start: \(error.localizedDescription)")
    }
}

extension MPCManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        delegate?.didChangeState(to: state, peerID: peerID)
        
        switch state {
        case .connected:
            print("Connected: \(peerID.displayName)")
            connectedPeer = peerID
        case .connecting:
            print("Connecting: \(peerID.displayName)")
        case .notConnected:
            print("Not Connected: \(peerID.displayName)")
        @unknown default:
            fatalError("Unknown state: \(state)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // Handle received data
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Handle received stream
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // Handle resource reception
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // Handle resource reception completion
    }
}

/*
 // These delegate protocols might be used for a more detailed report of connection changes
 protocol MPCManagerDelegate {
 //    func connecting()
 //    func connected()
 //    func notConnected()
 
 //    func foundPeer()
 //    func lostPeer()
 //    func invitationWasReceived(fromPeer: String)
 //    func connectedWithPeer(peerID: MCPeerID)
 }
 */

/*
 class MPCManager: NSObject {
 
 var connectedRightNow: Bool {
 
 get {
 return self.connectedPeer != nil
 }
 }
 
 static let instance = MPCManager()
 
 var delegate: MPCManagerDelegate?
 
 //    var session: MCSession!
 
 // TODO: Is the encryption still responsible for Multipeer connection issues?
 lazy var session : MCSession = {
 let session = MCSession(peer: self.peer, securityIdentity: nil, encryptionPreference: .optional)
 session.delegate = self
 return session
 }()
 
 var peer: MCPeerID!
 
 var browserService: MCNearbyServiceBrowser?
 var advertiserService: MCNearbyServiceAdvertiser?
 
 var connectedPeer: MCPeerID?
 
 var invitationHandler: ((Bool, MCSession?)->Void)!
 
 
 override init() {
 super.init()
 
 peer = MCPeerID(displayName: UIDevice.current.name)
 
 //        session = MCSession(peer: peer)
 session = MCSession(peer: peer, securityIdentity: nil, encryptionPreference: .required)
 session.delegate = self
 }
 
 deinit {
 
 if let a = self.advertiserService {
 a.stopAdvertisingPeer()
 }
 
 if let b = self.browserService {
 b.stopBrowsingForPeers()
 }
 }
 
 // MARK: Custom start/stop implementation
 
 func startAdvertising() {
 
 advertiserService = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: Constants.serviceTypeName)
 advertiserService!.delegate = self
 advertiserService!.startAdvertisingPeer()
 }
 
 func stopAdvertising() {
 
 advertiserService!.stopAdvertisingPeer()
 }
 
 func startBrowsing() {
 
 browserService = MCNearbyServiceBrowser(peer: peer, serviceType: Constants.serviceTypeName)
 browserService!.delegate = self
 browserService!.startBrowsingForPeers()
 }
 
 func stopBrowsing() {
 
 browserService!.stopBrowsingForPeers()
 }
 
 // MARK: Send Message
 
 func send(name: String, value: Int, image: UIImage) throws {
 
 let imageAsData: Data = image.pngData()!
 
 let message = Message(app: Constants.appName,
 user: name,
 score: value,
 imageData: imageAsData)
 
 let payload = try JSONEncoder().encode(message)
 
 guard let peer = connectedPeer else {
 debugPrint("Message NOT send to Apple TV!")
 return
 }
 
 try self.session.send(payload, toPeers: [peer], with: .reliable)
 
 }
 
 /*
  func send(text: String) throws {
  let message = Message(body: text)
  let payload = try JSONEncoder().encode(message)
  
  guard let peer = connectedPeer else {
  debugPrint("Message NOT send to Apple TV!")
  return
  }
  
  try self.session.send(payload, toPeers: [peer], with: .reliable)
  
  }
  */
 }
 
 // MARK: - MCNearbyServiceAdvertiser Delegate
 
 
 extension MPCManager: MCNearbyServiceAdvertiserDelegate {
 func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
 self.invitationHandler = invitationHandler
 
 // invitation received
 
 self.invitationHandler(true, self.session)
 
 //        delegate?.invitationWasReceived(fromPeer: peerID.displayName)
 }
 
 func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
 debugPrint("MPCManager advertising FAILED: \(error)")
 }
 }
 
 // MARK: - MCNearbyServiceBrowser Delegate
 
 extension MPCManager: MCNearbyServiceBrowserDelegate {
 func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
 browserService!.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
 
 
 // peer found
 //        delegate?.foundPeer()
 }
 
 func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
 
 connectedPeer = nil
 
 // peer lost
 //        delegate?.lostPeer()
 }
 
 func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
 debugPrint("MPCManager Browser could not start: \(error.localizedDescription)")
 }
 
 }
 
 
 // MARK: - MCSessionDelegate
 
 extension MPCManager: MCSessionDelegate {
 
 /*
  func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
  certificateHandler(true)
  }
  */
 
 func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
 
 var currentState = 0
 
 switch state {
 case MCSessionState.connecting:
 
 currentState = 1
 //            delegate?.connecting()
 // indicate it on your UI for example
 
 case MCSessionState.connected:
 
 currentState = 2
 // some UI changes
 connectedPeer = peerID
 //            delegate?.connectedWithPeer(peerID: peerID)
 //            delegate?.connected()
 
 case MCSessionState.notConnected:
 
 currentState = 0
 
 connectedPeer = nil
 debugPrint("Did not connect to session: \(session)")
 //            delegate?.notConnected()
 @unknown default:
 // A propably new case has been added meanwhile, check documentation
 fatalError("Unknown connection state for MCSessionState: \(state)")
 
 }
 
 DispatchQueue.main.async {
 NotificationCenter.default.post(name: Constants.connectionStateNotification, object: nil, userInfo: ["state": currentState])
 }
 
 }
 
 func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
 
 if let message = try? JSONDecoder().decode(Message.self, from: data) {
 
 // message received
 NotificationCenter.default.post(name: Constants.messageReceivedNotification, object: nil, userInfo: ["message": message])
 }
 
 }
 
 func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
 
 }
 
 func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
 
 }
 
 func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
 
 }
 
 }
 */
