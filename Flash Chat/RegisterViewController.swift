//
//  RegisterViewController.swift
//  Flash Chat
//
//  This is the View Controller which registers new users with Firebase
//

import UIKit
import FirebaseAuth
import SVProgressHUD

class RegisterViewController: UIViewController {

    
    //Pre-linked IBOutlets

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!    
    @IBOutlet weak var errorLabel: RNLabel!
    @IBOutlet weak var registerButton: UIButton!
    
    var userService: UserService?
    var tapViewGesture: UIGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userService = UserService()
        errorLabel.adjustsFontSizeToFitWidth = true
        errorLabel.isHidden = true
        errorLabel.setBackgroundColor(.white, paddingLeft: 10.0)
        errorLabel.setLineHeight(21.0, with: 0, with: nil)
        tapViewGesture = UITapGestureRecognizer(target: self, action: #selector(handlerEventTapView(gesture:)))
        self.view.addGestureRecognizer(tapViewGesture!)
    }
    
    @IBAction func registerPressed(_ sender: AnyObject) {
        //TODO: Set up a new user on our Firbase database
        var errorText = ""
        if !Validator.isSuccessEmailAddress(emailTextfield.text) {
            errorText += "Error is incorrect"
        }
        if !Validator.isSuccessPassword(passwordTextfield.text) {
            errorText += errorText == "" ? "Password is incorrect" : "\nPassword is incorrect"
        }
        if errorText != "" {
            showErrorLabel(with: errorText)
            return
        }
        SVProgressHUD.show()
        self.view.alpha = 0.5
        registerButton.isEnabled = false
        userService?.register(email: emailTextfield.text!, password: passwordTextfield.text!, image: nil, completion: {[weak self] user, error in
            if error != nil {
                DispatchQueue.main.async {
                    self?.showErrorLabel(with: "Register unsuccessful")
                    SVProgressHUD.dismiss()
                    self?.view.alpha = 1.0
                    self?.registerButton.isEnabled = true
                }
            }
            else {
                DispatchQueue.main.async {
                    self?.hideErrorLabel()
                    SVProgressHUD.dismiss()
                    self?.view.alpha = 1.0
                    self?.registerButton.isEnabled = true
                    self?.showGroupViewController()
                }
            }
        })
    }
    
    private func showErrorLabel(with text: String) {
        errorLabel.text = text
        errorLabel.isHidden = false
    }
    
    private func hideErrorLabel() {
        if !errorLabel.isHidden {
            errorLabel.text = ""
            errorLabel.isHidden = true
        }
    }
    
    // vo hieu hoa perform segue
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
    
    private func showGroupViewController() {
        let groupVC = self.storyboard?.instantiateViewController(withIdentifier: "GroupViewController") as! GroupViewController
        self.navigationController?.pushViewController(groupVC, animated: true)
    }
    
    @objc func handlerEventTapView(gesture: UIGestureRecognizer) {
        if emailTextfield.isFirstResponder {
            emailTextfield.resignFirstResponder()
        }
        if passwordTextfield.isFirstResponder {
            passwordTextfield.resignFirstResponder()
        }
    }
    
}
