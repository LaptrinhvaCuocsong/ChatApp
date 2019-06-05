//
//  Dictionary+Account.swift
//  Flash Chat
//
//  Created by nguyen manh hung on 5/30/19.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import Foundation

extension Dictionary where Key == String {
    
    var email: String? {
        return self["email"] as? String
    }
    
    var username: String? {
        return self["username"] as? String
    }
    
    var userId: String? {
        return self["userId"] as? String
    }
    
}
