//
//  AccountService.swift
//  Flash Chat
//
//  Created by nguyen manh hung on 5/31/19.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import FirebaseFirestore

class AccountService: NSObject {

    static let share = AccountService()
    
    let db = Firestore.firestore()
    var startDocSnapshot: DocumentSnapshot?
        
    func fetchAccount(completion: (([Account]?, Error?) -> Void)?) {
        if let docSnapshot = startDocSnapshot {
            db.collection("accounts").start(afterDocument: docSnapshot).limit(to: 25).getDocuments {[weak self] querySnapshot, error in
                self?.getAccounts(querySnapshot: querySnapshot, error: error, completion: completion)
                if let lastDocSnapshot = querySnapshot?.documents.last {
                    self?.startDocSnapshot = lastDocSnapshot
                }
            }
        }
        else {
            db.collection("accounts").limit(to: 25).getDocuments {[weak self] querySnapshot, error in
                self?.getAccounts(querySnapshot: querySnapshot, error: error, completion: completion)
                self?.startDocSnapshot = querySnapshot?.documents.last
            }
        }
    }
    
    func getAccount(accountId: String, completion: ((Account?, Error?) -> Void)?) {
        db.collection("accounts").whereField("userId", isEqualTo: accountId).getDocuments { (query, error) in
            if error == nil {
                if let doc = query?.documents.first {
                    let data = doc.data()
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
    
    private func getAccounts(querySnapshot: QuerySnapshot?, error: Error?, completion: (([Account]?, Error?) -> Void)?) {
        if error == nil {
            var accounts = [Account]()
            for doccument in querySnapshot?.documents ?? [] {
                let data = doccument.data()
                let acc = Account(username: data.username, email: data.email, userId: data.userId)
                accounts.append(acc)
            }
            if let com = completion {
                com(accounts, nil)
            }
        }
        else {
            if let com = completion {
                com(nil, error)
            }
        }
    }
    
}
