//
//  AlertService.swift
//  Flash Chat
//
//  Created by nguyen manh hung on 5/29/19.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit

class AlertService: NSObject {

    static let share = AlertService()
    
    func presentFormEnterUsername(parentVC: UIViewController, animation: Bool, title: String?, message: String?, completion: @escaping (UITextField) -> Void) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addTextField { textFiled in
            textFiled.placeholder = "Username"
        }
        alertVC.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            completion(alertVC.textFields!.first!)
        }))
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        parentVC.present(alertVC, animated:animation , completion: nil)
    }
    
    func presentMessage(parentVC: UIViewController, animation: Bool, title: String?, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        parentVC.present(alertVC, animated: animation, completion: nil)
    }
    
}
