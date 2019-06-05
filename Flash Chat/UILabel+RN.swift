//
//  UILabel+RN.swift
//  Flash Chat
//
//  Created by nguyen manh hung on 5/24/19.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit

extension UILabel {
    
    func setLineHeight(_ lineHeight: Double, with numberOfLines: Int, with lineBreakMode: NSLineBreakMode?) {
        if let text = self.text {
            self.numberOfLines = numberOfLines
            let attr = NSMutableAttributedString(string: text)
            let paramStyle = NSMutableParagraphStyle()
            paramStyle.minimumLineHeight = CGFloat(lineHeight)
            paramStyle.maximumLineHeight = CGFloat(lineHeight)
            paramStyle.lineBreakMode = lineBreakMode ?? NSLineBreakMode.byTruncatingTail
            attr.addAttribute(NSAttributedStringKey.paragraphStyle, value: paramStyle, range: NSRange(location: 0, length: text.count))
            self.attributedText = attr
        }
    }
    
}
