//
//  Dictionary+MessageGroup.swift
//  Flash Chat
//
//  Created by nguyen manh hung on 6/2/19.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import Foundation

extension Dictionary where Key == String {
    
    var groupName: String? {
        return self["groupName"] as? String
    }
    
    var messages: [[String:String]]? {
        return self["message"] as? [[String:String]]
    }
    
}
