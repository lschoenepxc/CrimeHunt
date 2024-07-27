//
//  VerticalAlignedLabel.swift
//  Crime Beacon Hunt
//
//  Created by Laura Schöne on 27.07.24.
//

import UIKit

class VerticalAlignedLabel: UILabel {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func drawText(in rect: CGRect) {
            var newRect = rect
            switch contentMode {
            case .top:
                newRect.size.height = sizeThatFits(rect.size).height
            case .bottom:
                let height = sizeThatFits(rect.size).height
                newRect.origin.y += rect.size.height - height - 10
                newRect.origin.x = 10
                newRect.size.height = height
            default:
                ()
            }
            
            super.drawText(in: newRect)
        }

}
