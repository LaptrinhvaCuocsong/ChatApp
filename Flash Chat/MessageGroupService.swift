//
//  MessageGroupService.swift
//  Flash Chat
//
//  Created by nguyen manh hung on 6/2/19.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import FirebaseFirestore

class MessageGroupService: NSObject {

    static let share = MessageGroupService()
    let db = Firestore.firestore()
    
    func findMessageGroup(groupId: [String], groupName: String, completion: ((MessageGroup?, Error?) -> Void)?) {
        db.collection("messages").whereField("groupId", isEqualTo: groupId.sorted().joined(separator: "+")).getDocuments {[weak self] query, error in
            if error == nil {
                if let doc = query?.documents.first {
                    let data = doc.data()
                    var messages = [Message]()
                    if let array = data.messages {
                        for i in array {
                            messages.append(Message(accountId: i.accountId, message: i.message))
                        }
                    }
                    let messageGroup = MessageGroup(groupId: doc.documentID,groupName: data.groupName, groupAccountId: groupId, messages: messages)
                    if let com = completion {
                        com(messageGroup, nil)
                    }
                }
                else {
                    self?.createMessageGroup(groupId: groupId, groupName: groupName, completion: completion)
                }
            }
            else {
                if let com = completion {
                    com(nil, error)
                }
            }
        }
    }
    
    func createMessageGroup(groupId: [String], groupName: String, completion: ((MessageGroup?, Error?) -> Void)?) {
        let doc = db.collection("messages").addDocument(data: [
            "groupId": groupId.sorted().joined(separator: "+"),
            "groupName": groupName,
            "message": [String:String]()
            ])
        let messageGroup = MessageGroup(groupId: doc.documentID,groupName: groupName, groupAccountId: groupId, messages: [Message]())
        if let com = completion {
            com(messageGroup, nil)
        }
    }
    
    func updateMessageGroup(messageGroup: MessageGroup, completion: ((Error?) -> Void)?) {
        var messages = [[String:String]]()
        if let array = messageGroup.messages {
            for i in array {
                messages.append([
                    "accountId": i.accountId!,
                    "message": i.message!
                ])
            }
        }
        db.collection("messages").document(messageGroup.groupId!).updateData([
            "message": messages
            ], completion: { error in
                if let com = completion {
                    com(error)
                }
        })
    }
    
    func getMessageGroups(completion: (([MessageGroup]?, Error?) -> Void)?) {
        db.collection("messages").getDocuments {[weak self] (query, error) in
            if error == nil {
                if let docs = query?.documents {
                    let messageGroups = self?.getMessageGroups(docs: docs)
                    if let com = completion {
                        com(messageGroups, nil)
                    }
                }
                else {
                    if let com = completion {
                        com(nil, error)
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
    
    func getMessageGroups(docs: [QueryDocumentSnapshot]) -> [MessageGroup] {
        let groupId = UserService.share.currentAccount!.userId!
        var messageGroups = [MessageGroup]()
        for doc in docs {
            let data = doc.data()
            let groupIds = (data["groupId"] as! String).split(separator: "+").map({ (str) -> String in
                String(str)
            })
            if (groupIds.contains(groupId)) {
                var messages = [Message]()
                if let array = data.messages {
                    for i in array {
                        messages.append(Message(accountId: i.accountId, message: i.message))
                    }
                }
                if (messages.count != 0) {
                    let mg = MessageGroup(groupId: doc.documentID, groupName: data.groupName, groupAccountId: groupIds, messages: messages)
                    messageGroups.append(mg)
                }
            }
        }
        return messageGroups
    }
    
}
