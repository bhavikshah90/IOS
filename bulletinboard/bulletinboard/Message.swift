//
//  Message.swift
//  bulletinboard
//
//  Created by bhavik on 14/12/18.
//  Copyright © 2018 bhavik. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
class Message{
    var fromId: String?
    var toId: String?
    var text: String?
 //   var timestamp: Double?
    
    func chatPartnerId() -> String?{
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
//        let chatPartnerId: String?
//        if fromId == Auth.auth().currentUser.uid{
//            chatPartnerId = toId
//        }
//        else{
//            chatPartnerId = fromId
//        }
    }
}
