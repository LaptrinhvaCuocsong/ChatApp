//
//  RNLabel.swift
//  Flash Chat
//
//  Created by nguyen manh hung on 5/24/19.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit

class RNLabel: UILabel {
    
    var inset: UIEdgeInsets?
    
    override var intrinsicContentSize: CGSize {
        let intrisicSize = super.intrinsicContentSize
        return CGSize(width: intrisicSize.width, height: intrisicSize.height + 10.0)
    }
    
    func setBackgroundColor(_ color: UIColor, paddingLeft: Double = 0.0) {
        self.backgroundColor = color
        inset = UIEdgeInsets(top: 0.0, left: CGFloat(paddingLeft), bottom: 0.0, right: 0.0)
    }
    
    override func drawText(in rect: CGRect) {
        if let i = inset {
            super.drawText(in: UIEdgeInsetsInsetRect(rect, i))
            return
        }
        super.drawText(in: rect)
    }
    
}
