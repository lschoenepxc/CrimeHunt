//
//  UIImage+Squared.swift
//  Universe Hunt
//
//  Created by Heizo Schulze on 03.07.24.
//

import UIKit

extension UIImage {
    
    // Function to crop the image to a square
    func croppedToSquare() -> UIImage? {
        let refWidth = CGFloat((self.cgImage!.width))
        let refHeight = CGFloat((self.cgImage!.height))
        let cropSize = refWidth > refHeight ? refHeight : refWidth
        
        let x = (refWidth - cropSize) / 2.0
        let y = (refHeight - cropSize) / 2.0
        
        let cropRect = CGRect(x: x, y: y, width: cropSize, height: cropSize)
        let imageRef = self.cgImage?.cropping(to: cropRect)
        let cropped = UIImage(cgImage: imageRef!, scale: 0.0, orientation: self.imageOrientation)
        
        return cropped
    }
    
    // Function to resize the image without distortion
    func resized(to targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    // Combined function to crop and resize
    func croppedAndResized(to size: CGSize) -> UIImage? {
        guard let squareImage = self.croppedToSquare() else { return nil }
        return squareImage.resized(to: size)
    }
}
