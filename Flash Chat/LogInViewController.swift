//
//  LogInViewController.swift
//  Flash Chat
//
//  This is the view controller where users login


import UIKit
import FirebaseAuth
import SVProgressHUD

class LogInViewController: UIViewController {

    //Textfields pre-linked with IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    @IBOutlet weak var errorLabel: RNLabel!
    @IBOutlet weak var loginButton: UIButton!
    
    var userService: UserService?
    var tapViewGesture: UIGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userService = UserService()
        errorLabel.adjustsFontSizeToFitWidth = true
        errorLabel.isHidden = true
        errorLabel.setBackgroundColor(.white, paddingLeft: 10.0)
        errorLabel.setLineHeight(21.0, with: 1, with: nil)
        tapViewGesture = UITapGestureRecognizer(target: self, action: #selector(handlerEventTapView(gesture:)))
        self.view.addGestureRecognizer(tapViewGesture!)
    }
   
    @IBAction func logInPressed(_ sender: AnyObject) {
        //TODO: Log in the user
        if !Validator.isSuccessEmailAddress(emailTextfield.text) {
            showErrorLabel(with: "Email is incorrect")
            return
        }
        SVProgressHUD.show()
        self.view.alpha = 0.5
        loginButton.isEnabled = false
        userService?.login(email: emailTextfield.text!, password: passwordTextfield.text!, completion: {[weak self] user, error in
            if error != nil {
                DispatchQueue.main.async {
                    self?.showErrorLabel(with: "Email or password is incorrect")
                    SVProgressHUD.dismiss()
                    self?.view.alpha = 1.0
                    self?.loginButton.isEnabled = true
                }
            }
            else {
                DispatchQueue.main.async {
                    self?.hideErrorLabel()
                    SVProgressHUD.dismiss()
                    self?.view.alpha = 1.0
                    self?.loginButton.isEnabled = true
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
