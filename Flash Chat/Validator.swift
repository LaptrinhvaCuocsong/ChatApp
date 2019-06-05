//
//  Validator.swift
//  Flash Chat
//
//  Created by nguyen manh hung on 5/24/19.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit

class Validator: NSObject {

    static func isSuccessEmailAddress(_ email: String?) -> Bool {
        if let e = email {
            let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            return predicate.evaluate(with: e)
        }
        return false
    }
    
    static func isSuccessPassword(_ password: String?) -> Bool {
        if let p = password {
            let regex = "[a-zA-Z0-9]{8,}"
            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            return predicate.evaluate(with: p)
        }
        return false
    }
    
}
