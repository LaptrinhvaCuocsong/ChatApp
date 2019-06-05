//
//  SearchAccountViewController.swift
//  Flash Chat
//
//  Created by nguyen manh hung on 5/31/19.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol SearchAccountViewControllerDelegate: class {
    
    func dismissViewController(animated: Bool, completion: (() -> Void)?)
    
}

class SearchAccountViewController: UIViewController, ChatViewControllerDelegate {

    weak var delegate: SearchAccountViewControllerDelegate?
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var chooseBarButton: UIBarButtonItem!
    
    
    let accountService =  AccountService()
    var searchAccounts = [Account]()
    var chooseAccounts = Set<Int>() {
        didSet {
            if chooseAccounts.count > 0 {
                chooseBarButton.isEnabled = true
            }
            else {
                chooseBarButton.isEnabled = false
            }
        }
    }
    var isBackFromChatViewController = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.separatorColor = .clear
        searchTableView.register(UINib(nibName: "AccountCell", bundle: nil), forCellReuseIdentifier: "AccountCell")
        chooseBarButton.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isBackFromChatViewController {
            return
        }
        SVProgressHUD.show()
        self.view.alpha = 0.5
        accountService.fetchAccount {[weak self] accounts, error in
            if error != nil {
                SVProgressHUD.dismiss()
                self?.view.alpha = 1.0
            }
            else {
                if let accs = accounts {
                    SVProgressHUD.dismiss()
                    self?.view.alpha = 1.0
                    self?.searchAccounts.append(contentsOf: accs.filter({ acc -> Bool in
                        acc.userId != UserService.share.currentAccount?.userId
                    }))
                    self?.searchTableView.reloadData()
                }
            }
        }
    }

    @IBAction func chooseAccountGoToChat(_ sender: Any) {
        isBackFromChatViewController = true
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        var array = [Account]()
        for i in chooseAccounts {
            array.append(searchAccounts[i])
        }
        array.append(UserService.share.currentAccount!)
        let groupAccountId = array.map { (acc) -> String in
            acc.userId!
        }
        let groupAccountName = array.map { (acc) -> String in
            acc.username ?? acc.email!
        }.joined(separator: ", ")
        chatVC.groupAccountId = groupAccountId
        chatVC.groupAccountName = groupAccountName
        chatVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: chatVC, action: #selector(chatVC.dismissVC))
        chatVC.delegate = self
        let navigationCharVC = UINavigationController(rootViewController: chatVC)
        present(navigationCharVC, animated: true, completion: nil)
    }
    
    @IBAction @objc func cancelSearch(_ sender: Any) {
        delegate?.dismissViewController(animated: true, completion: nil)
    }
    
    //MARK: ChatViewControllerDelegate
    
    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        delegate?.dismissViewController(animated: animated, completion: completion)
    }

}

extension SearchAccountViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchAccounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath) as! AccountCell
        cell.setContent(account: self.searchAccounts[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if chooseAccounts.contains(indexPath.row) {
            cell?.accessoryType = .none
            chooseAccounts.remove(indexPath.row)
        }
        else {
            cell?.accessoryType = .checkmark
            chooseAccounts.insert(indexPath.row)
        }
    }
    
}
