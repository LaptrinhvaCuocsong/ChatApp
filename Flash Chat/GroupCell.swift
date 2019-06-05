//
//  GroupCell.swift
//  Flash Chat
//
//  Created by nguyen manh hung on 5/27/19.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {

    @IBOutlet weak var groupMessage: UILabel!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var groupImage: UIImageView!
    
    func setContent(groupImg: UIImage?, groupName: String, groupMessage: String) {
        if let img = groupImg {
            self.groupImage.image = img
        }
        else {
            self.groupImage.image = UIImage(named: "profil")
        }
        let groupNames = (groupName as NSString).components(separatedBy: ", ")
        let groupName = groupNames.filter({ (item) -> Bool in
            item != UserService.share.currentAccount!.username ?? UserService.share.currentAccount!.email
        }).joined(separator: ", ")
        self.groupName.text = groupName
        self.groupMessage.text = groupMessage
    }

}
