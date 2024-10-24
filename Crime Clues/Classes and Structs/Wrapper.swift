import Foundation
import UIKit

// MARK: - Constants accross iOS and TV

// we need these data across both targets (iOS app and tvOS app)
struct Constants {
    // Make sure all app names are identical in all Constants files!
    static let appName = "MasterScore" // the Apple TV app
    static let adminName = "Admin" // the Admin app
    // TODO: App Names
    static let appNames = ["Universe Hunt", "Crime Clues", "Treasure Hunt", "Bombenentschaerfer"]
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

struct Ort {
    let ortID: Int
    let name: String
    let tabCategory: String
    let picture: String
    let quizNo: Int
    let indizien: [String]
    let beaconMajor: Int
    let beaconMinor: Int
}

struct Verdaechtiger {
    let name: String
    let job: String
    let alter: Int
    let motiv: String
    let info: String
    let pic: String
}

struct Tatwaffe {
    let bezeichnung: String
    let methode: String
    let info: String
    let pic: String
}

struct Tatort {
    let ort: String
    let beschreibung: String
    let info: String
    let pic: String
}

struct Akte {
    let verdaechtige: [Verdaechtiger]
    let tatwaffen: [Tatwaffe]
    let tatorte: [Tatort]
}

// MARK: - Wrapping Game Data
// wrapper format, suitable for all Hunts
struct GameMessage {
    var app: String = "Crime Clues" // distinguish the data for showing all on one screen at AppleTV
    let teamName: String // name of person/team
    let score: Int // result of person/team
    let image: UIImage // image of person/team
    let seconds: Int // elapsed seconds of game
}

struct BeaconSettings {
    let maxiUUID: String = "ACFD065E-C3C0-11E3-9BBE-1A514932AC01"
    let miniUUID: String = "ACFD065E-C3C0-11E3-9BBE-1A514932AC01"
}

// Funktion zum Verpixeln des Bildes
func pixelateImage(image: UIImage) -> UIImage? {
    let inputImage = CIImage(image: image)  // UIImage in CIImage umwandeln
        
    // Einen CIFilter erstellen, um den Pixelate-Effekt anzuwenden
    let filter = CIFilter(name: "CIPixellate")!
    filter.setValue(inputImage, forKey: kCIInputImageKey)
        
    // Pixelgröße einstellen (Je höher der Wert, desto stärker die Verpixelung)
    filter.setValue(40, forKey: kCIInputScaleKey)
        
        // Gefiltertes Bild erzeugen
    let context = CIContext()
    if let outputImage = filter.outputImage,
        let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
        return UIImage(cgImage: cgImage)
    }
    return nil
}
