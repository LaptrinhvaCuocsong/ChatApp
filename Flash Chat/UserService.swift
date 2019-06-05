//
//  UserService.swift
//  Flash Chat
//
//  Created by nguyen manh hung on 5/23/19.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class UserService: NSObject {

    static let share = UserService()
    
    let db = Firestore.firestore()
    var currentAccount: Account?
    
    func login(email: String, password: String, completion: ((Account?, Error?) -> Void)?) {
        weak var weakSelf = self
        Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            if error == nil {
                if let user = authDataResult?.user {
                    weakSelf?.getAccount(with: user.uid, completion: { acc, error in
                        if error == nil {
                            UserService.share.currentAccount = acc
                        }
                        if let com = completion {
                            com(acc, error)
                        }
                    })
                }
                else {
                    if let com = completion {
                        com(nil, nil)
                    }
                }
            }
            else {
                if let com = completion {
                    com(nil, error)
                }
            }
        }
    }
    
    func register(email: String, password: String, image: UIImage?, completion: ((Account?, Error?) -> Void)?) {
        weak var weakSelf = self
        Auth.auth().createUser(withEmail: email, password: password) { authDataResult, error in
            if error == nil {
                if let user = authDataResult?.user {
                    let acc = Account(username: nil, email: user.email, userId: user.uid)
                    UserService.share.currentAccount = acc
                    weakSelf?.addAccountToDatabase(account: acc)
                    if let com = completion {
                        com(acc, nil)
                    }
                }
                else {
                    if let com = completion {
                        com(nil, nil)
                    }
                }
            }
            else {
                if let com = completion {
                    com(nil, error)
                }
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        }catch {
            print(error.localizedDescription)
        }
    }
    
    func updateAccount(email: String, username: String, completion: ((Error?) -> Void)?) {
        currentAccount?.email = email
        currentAccount?.username = username
        db.collection("accounts").document(currentAccount!.userId!).updateData([
            "username": username,
            "email": email,
            "userId": currentAccount!.userId!
            ], completion: {error in
                if let com = completion {
                    com(error)
                }
        })
    }
    
    private func getAccount(with userId: String, completion: ((Account?, Error?) -> Void)?) {
        db.collection("accounts").whereField("userId", isEqualTo: userId).getDocuments { querySnapshot, error in
            if error == nil {
                if let queryDocSnapshot = querySnapshot?.documents.first {
                    let data = queryDocSnapshot.data()
                    let acc = Account(username: data.username, email: data.email, userId: data.userId)
                    if let com = completion {
                        com(acc, nil)
                    }
                }
                else {
                    if let com = completion {
                        com(nil, nil)
                    }
                }
            }
            else {
                if let com = completion {
                    com(nil, error)
                }
            }
        }
    }
    
    private func addAccountToDatabase(account: Account) {
        if let userId = account.userId {
            db.collection("accounts").document(userId).setData([
                "username": account.username ?? "",
                "email": account.email!,
                "userId": account.userId!
            ])
        }
    }
    
}
