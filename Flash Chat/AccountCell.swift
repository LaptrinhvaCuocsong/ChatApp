//
//  AccountCell.swift
//  Flash Chat
//
//  Created by nguyen manh hung on 5/31/19.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit

class AccountCell: UITableViewCell {

    @IBOutlet weak var accountImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    func setContent(account: Account?) {
        if account?.username != nil && account?.username != "" {
            nameLabel.text = account?.username
        }
        else {
            nameLabel.text = account?.email
        }
    }
    
}
