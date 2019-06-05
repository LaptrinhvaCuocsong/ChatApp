//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import FirebaseAuth
import SVProgressHUD
import FirebaseFirestore

protocol ChatViewControllerDelegate: class {
    
    func dismissViewController(animated: Bool, completion: (() -> Void)?)
    
}

class ChatViewController: UIViewController {

    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    weak var delegate: ChatViewControllerDelegate?
    var groupAccountId: [String]?
    var groupAccountName: String?
    var messageGroup: MessageGroup? {
        didSet {
            if messageGroup != nil {
                sendButton.isEnabled = true
            }
            else {
                sendButton.isEnabled = false
            }
        }
    }
    var messages = [Message]()
    var statusCells = Set<Int>()
    let kHeightMessageTextfield = 50.0
    var tapTableViewGesture: UIGestureRecognizer?
    let db = Firestore.firestore()
    var listener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.estimatedRowHeight = 100.0
        messageTableView.separatorColor = .clear
        //TODO: Set the tapGesture here:
        tapTableViewGesture = UITapGestureRecognizer(target: self, action: #selector(handlerEventTapTableView(gesture:)))
        messageTableView.addGestureRecognizer(tapTableViewGesture!)
        
        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        messageTableView.register(UINib(nibName: "LeftMessageCell", bundle: nil), forCellReuseIdentifier: "LeftMessageCell")
        sendButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(handlerEventShowKeyboard(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlerEventHideKeyboard(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let accGroupId = groupAccountId, let accGroupName = groupAccountName {
            SVProgressHUD.show()
            view.alpha = 0.5
            MessageGroupService.share.findMessageGroup(groupId: accGroupId, groupName: accGroupName) {[weak self] messageGroup, error in
                if error == nil {
                    if let item = messageGroup {
                        self?.initListener(groupId: item.groupId!)
                        self?.messageGroup = item
                        if let m = item.messages {
                            self?.messages = m
                            self?.messageTableView.reloadData()
                        }
                    }
                    SVProgressHUD.dismiss()
                    self?.view.alpha = 1.0
                }
                else {
                    SVProgressHUD.dismiss()
                    self?.view.alpha = 1.0
                    AlertService.share.presentMessage(parentVC: self!, animation: true, title: nil, message: "Connect error")
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        if let listener = self.listener {
            listener.remove()
        }
    }
    
    private func initListener(groupId: String) {
        listener = db.collection("messages").document(groupId).addSnapshotListener {[weak self] (docSnapshot, error) in
            if error == nil {
                if let data = docSnapshot?.data() {
                    var messages = [Message]()
                    if let array = data.messages {
                        for i in array {
                            messages.append(Message(accountId: i.accountId, message: i.message))
                        }
                    }
                    self?.messageGroup?.messages = messages
                    self?.messages = messages
                    self?.messageTableView.reloadData()
                }
            }
        }
    }

    @IBAction func sendPressed(_ sender: AnyObject) {
        //TODO: Send the message to Firebase and save it in our database
        if let text = messageTextfield.text {
            if !text.isEmpty {
                let message = Message(accountId: UserService.share.currentAccount?.userId, message: text)
                messages.append(message)
                let size = messages.count
                statusCells.insert(size - 1)
                messageTableView.reloadData()
                let messageGroupTemp = MessageGroup(groupId: messageGroup!.groupId!, groupName: messageGroup?.groupName, groupAccountId: messageGroup!.groupAccountId!, messages: messages)
                MessageGroupService.share.updateMessageGroup(messageGroup: messageGroupTemp) {[weak self] error in
                    if error == nil {
                        self?.statusCells.remove(size-1)
                        self?.messageTableView.reloadData()
                    }
                }
            }
        }
    }
    
    //TODO: Create the retrieveMessages method here:
    
    @objc func dismissVC() {
        delegate?.dismissViewController(animated: true, completion: nil)
    }
    
    @objc func handlerEventTapTableView(gesture: UITapGestureRecognizer) {
        messageTextfield.resignFirstResponder()
    }
    
    @objc func handlerEventShowKeyboard(notification: Notification) {
        if let userInfo = notification.userInfo {
            weak var weakSelf = self
            UIView.animate(withDuration: 0.5) {
                let keyboardFrame = userInfo["UIKeyboardFrameEndUserInfoKey"]! as! CGRect
                weakSelf?.heightConstraint.constant = CGFloat(weakSelf!.kHeightMessageTextfield) + keyboardFrame.size.height
                weakSelf?.view.layoutIfNeeded()
            }
        }
    }

    @objc func handlerEventHideKeyboard(notification: Notification) {
        weak var weakSelf = self
        UIView.animate(withDuration: 0.5) {
            weakSelf?.heightConstraint.constant = CGFloat(weakSelf!.kHeightMessageTextfield)
            weakSelf?.view.layoutIfNeeded()
        }
    }
    
    private func scrollToBottomOfTableView(animated: Bool) {
        let y = messageTableView.contentSize.height + messageTableView.contentInset.top + messageTableView.contentInset.bottom - 2*messageTableView.height
        if y >= 0 {
            messageTableView.setContentOffset(CGPoint(x: 0, y: y), animated: animated)
        }
    }
    
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        var cell: CustomMessageCell?
        if message.accountId == UserService.share.currentAccount?.userId {
            cell = tableView.dequeueReusableCell(withIdentifier: "LeftMessageCell", for: indexPath) as? CustomMessageCell
            if statusCells.contains(indexPath.row) {
                cell?.statusImageView.image = UIImage(named: "icon-not-done")
            }
            else {
                cell?.statusImageView.image = nil
            }
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? CustomMessageCell
        }
        cell?.setContent(accountId: message.accountId!, message: message.message!)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}

extension ChatViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.height {
            messageTableView.contentInset = UIEdgeInsets(top: CGFloat(0.0), left: CGFloat(0.0), bottom: CGFloat(24.0), right: CGFloat(0.0))
        }
    }
    
}
