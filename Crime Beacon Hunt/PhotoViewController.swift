//
//  SendViewController.swift
//  Universe Hunt
//
//  Created by Heizo Schulze on 27.06.24.
//

import UIKit
import AudioToolbox

class PhotoViewController: UIViewController {
    
    // MARK: - UI Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    
    // MARK: - Properties
    
    var seconds = 0
    var score = 0
    var pictureTaken = false
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        nameTextField.delegate = self
    }
    
    // MARK: - User Action
    
    @IBAction func takePicturePressed(_ sender: Any) {
        showImagePicker() // open system camera VC
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        
        let result = wrapData()
        
        if let game = result.game {
            
            if let finishVC = self.presentingViewController as? FinishViewController {
                finishVC.receiveGameMessage(game)
            } else {
                // should never happen, but added for safety
                showAlert(title: "Error in Hierarchy", message: "Something went terribly wrong.")
            }
            
        } else {
            showAlert(title: "Data Missing", message: result.message!)
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
    
    // MARK: - Data Entry
    
    func receiveGameDataForWrapping(seconds: Int, score: Int) {
        
        self.seconds = seconds
        self.score = score
    }
    
    // MARK: - Wrap Data
    
    func wrapData() -> (game: GameMessage?, message: String?) {
        guard let team = nameTextField.text, team.count > 2 else {
            print("Failed to get team name")
            return  (nil, "Team Name")
        }
        
        guard pictureTaken else {
            
            print("Failed to create image data")
            return  (nil, "Photo")
        }
        
        let image = photoImageView.image! // we are sure an image exists
        
        let game = GameMessage(teamName: team, score: self.score, image: image, seconds: self.seconds)
        return (game, nil)
    }
    
    // MARK: - Show Alert
    
    func showAlert(title: String, message: String) {
        // Step 1: Create the alert controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Step 2: Add an action to the alert
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Action handler (optional)
            print("OK button tapped")
        }
        alertController.addAction(okAction)
        
        // Optional: Add more actions if needed
        // let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        // alertController.addAction(cancelAction)
        
        // Step 3: Present the alert
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Show System Image Picker (Camera)
    
    func showImagePicker() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        } else {
            // Handle the case where the camera is not available (e.g., on a simulator)
            let alert = UIAlertController(title: "Camera not available", message: "This device does not have a camera.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
}

// MARK: - PickerController Delegate

extension PhotoViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            // Do something with the image, e.g., save it or display it in an UIImageView
            // Example: imageView.image = pickedImage
            let squareImage = pickedImage.croppedAndResized(to: CGSize(width: 300, height: 300))
            photoImageView.image = squareImage
            pictureTaken = true
            // print("Image picked: \(pickedImage)")
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - NavigationController Delegate

extension PhotoViewController: UINavigationControllerDelegate {
    
    // required: does even work when empty
    
}

// MARK: - TextField Delegate

extension PhotoViewController: UITextFieldDelegate {
    
    // required to close keyboard with hitting return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder() // close keyboard
        return true
    }
}
