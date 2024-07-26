//
//  Constants.swift
//  BLE
//
//  Created by Heizo Schulze on 05.11.19.
//  Copyright © 2019 fb2.th-owl.de. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Constants accross iOS and TV

// we need these data across both targets (iOS app and tvOS app)
struct Constants {
    // Make sure all app names are identical in all Constants files!
    static let appName = "MasterScore" // the Apple TV app
    static let adminName = "Admin" // the Admin app
    // TODO: App Names
    static let appNames = ["Universe Hunt", "Another", "Careful", "Somehow", "Playful"]
    static let messageReceivedNotification = Notification.Name("DeviceDidReceiveMessage")
    static let connectionStateNotification = Notification.Name("DeviceDidChangedConnectionState")
    static let serviceTypeName = "beacon-hunt"
}

// MARK: - Wrapping Data for VC

struct QuizQuestion {
    let question: String
    let answers: [String]
    let correctAnswerIndex: Int
}

struct QuizAnswer {
    let quizNo: Int
    let answerIndex: Int
    let quizTime: Int // seconds for a single quiz
}

// MARK: - Wrapping Game Data
// wrapper format, suitable for all Hunts
struct GameMessage {
    var app: String = "Universe Hunt" // distinguish the data for showing all on one screen at AppleTV
    let teamName: String // name of person/team
    let score: Int // result of person/team
    let image: UIImage // image of person/team
    let seconds: Int // elapsed seconds of game
}

struct BeaconSettings {
    let maxiUUID: String = "ACFD065E-C3C0-11E3-9BBE-1A514932AC01"
    let miniUUID: String = "ACFD065E-C3C0-11E3-9BBE-1A514932AC01"
}
