//
//  UIView+RN.swift
//  Flash Chat
//
//  Created by nguyen manh hung on 5/25/19.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit

extension UIView {
    
    var width: CGFloat {
        get {
            return self.frame.size.width
        }
    }
    
    var height: CGFloat {
        get {
            return self.frame.size.height
        }
    }
    
    var left: CGFloat {
        get {
            return self.frame.origin.x
        }
    }
    
    var right: CGFloat {
        get {
            return self.frame.origin.x + self.frame.size.width
        }
    }
    
    var top: CGFloat {
        get {
            return self.frame.origin.y
        }
    }
    
    var bottom: CGFloat {
        get {
            return self.frame.origin.y + self.frame.size.height
        }
    }
    
}
