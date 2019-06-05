//
//  Dictionary+Message.swift
//  Flash Chat
//
//  Created by nguyen manh hung on 6/2/19.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import Foundation

extension Dictionary where Key == String {
    
    var accountId: String? {
        return self["accountId"] as? String
    }
    
    var message: String? {
        return self["message"] as? String
    }
    
}
