//
//  CustomMessageCell.swift
//  Flash Chat
//
//  Created by Angela Yu on 30/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit

class CustomMessageCell: UITableViewCell {


    @IBOutlet var messageBackground: UIView!
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var messageBody: UILabel!
    @IBOutlet var senderUsername: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code goes here
        messageBackground.layer.cornerRadius = 5.0
    }

    func setContent(username: String?, message: String, avatar: UIImage?) {
        senderUsername.text = username
        messageBody.text = message
        messageBody.numberOfLines = 0
        if let img = avatar {
            avatarImageView.image = img
        }
        else {
            avatarImageView.image = UIImage(named: "profil")
        }
    }
    
    func setContent(accountId: String, message: String) {
        self.messageBody.text = message
        AccountService.share.getAccount(accountId: accountId) {[weak self] (account, error) in
            if error == nil {
                if let acc = account {
                    self?.senderUsername.text = acc.username ?? acc.email
                }
            }
        }
    }

}
