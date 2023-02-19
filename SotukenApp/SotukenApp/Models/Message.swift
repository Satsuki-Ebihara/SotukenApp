//
//  Message.swift
//  chatAppWithFirebase
//
//  Created by 海老原颯希 on 2023/02/12.
//

import Foundation
import Firebase

class Message {
    let username: String
    let message: String
    let uid: String
    let createdAt: Timestamp
    
    var partnerUser: User?
    
    init(dic: [String: Any]) {
        self.username = dic["username"] as? String ?? ""
        self.message = dic["message"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
}
