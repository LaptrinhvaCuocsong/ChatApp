//
//  GroupViewController.swift
//  Flash Chat
//
//  Created by nguyen manh hung on 5/27/19.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import SVProgressHUD
import FirebaseFirestore

class GroupViewController: UIViewController, SearchAccountViewControllerDelegate {
    
    @IBOutlet weak var groupTableView: UITableView!
    
    var groupMessages = [MessageGroup]()
    let db = Firestore.firestore()
    var listener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutAndBackToRootViewController))
        // Do any additional setup after loading the view.
        groupTableView.delegate = self
        groupTableView.dataSource = self
        groupTableView.rowHeight = 80.0
        groupTableView.estimatedRowHeight = 80.0
        groupTableView.register(UINib(nibName: "GroupCell", bundle: nil), forCellReuseIdentifier: "GroupCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showPopupEnterUsername()
        loadGroupMessage()
        initListener()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let listener = self.listener {
            listener.remove()
        }
    }
    
    private func showPopupEnterUsername() {
        if UserService.share.currentAccount?.username == nil {
            AlertService.share.presentFormEnterUsername(parentVC: self, animation: true, title: "Enter username", message: nil) {[weak self] usernameTextField in
                self?.dismiss(animated: true, completion: nil)
                SVProgressHUD.show()
                self?.view.alpha = 0.5
                if let email = UserService.share.currentAccount?.email, let username = usernameTextField.text {
                    UserService.share.updateAccount(email: email, username: username, completion: { error in
                        if error != nil {
                            DispatchQueue.main.async {
                                SVProgressHUD.dismiss()
                                self?.view.alpha = 1.0
                                AlertService.share.presentMessage(parentVC: self!, animation: true, title: nil, message: "Update username error")
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                self?.view.alpha = 1.0
                                SVProgressHUD.dismiss()
                            }
                        }
                    })
                }
            }
        }
    }
    
    private func loadGroupMessage() {
        MessageGroupService.share.getMessageGroups {[weak self] (messageGroups, error) in
            if error == nil {
                if let mgs = messageGroups {
                    self?.groupMessages = mgs
                    self?.groupTableView.reloadData()
                }
            }
        }
    }
    
    private func initListener() {
        listener = db.collection("messages").addSnapshotListener({[weak self] (querySnapshot, error) in
            if error == nil {
                if let docs = querySnapshot?.documents {
                    self?.groupMessages = MessageGroupService.share.getMessageGroups(docs: docs)
                    self?.groupTableView.reloadData()
                }
            }
        })
    }
    
    @objc func logoutAndBackToRootViewController() {
        UserService.share.logout()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func addGroupMessage(_ sender: Any) {
        let searchAccVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchAccountViewController") as! SearchAccountViewController
        searchAccVC.delegate = self
        present(searchAccVC, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.height {
            groupTableView.contentInset = UIEdgeInsets(top: CGFloat(0.0), left: CGFloat(0.0), bottom: CGFloat(24.0), right: CGFloat(0.0))
        }
    }
    
    // vo hieu hoa segue
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
    
    //MARK: SearchAccountViewControllerDelegate
    
    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        dismiss(animated: animated, completion: completion)
    }
    
}

extension GroupViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! GroupCell
        let groupMessage = groupMessages[indexPath.row]
        cell.setContent(groupImg: nil, groupName: groupMessage.groupName!, groupMessage: groupMessage.messages!.last!.message!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let groupMessage = groupMessages[indexPath.row]
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatVC.groupAccountId = groupMessage.groupAccountId
        chatVC.groupAccountName = groupMessage.groupName
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
}
