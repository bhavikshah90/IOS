//
//  Constants.swift
//  bulletinboard
//
//  Created by bhavik on 13/12/18.
//  Copyright © 2018 bhavik. All rights reserved.
//

import Firebase

struct Constants
{
    struct refs
    {
        static let databaseRoot = Database.database().reference()
        static let databaseChats = databaseRoot.child("chats")
    }
}
