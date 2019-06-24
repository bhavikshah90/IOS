//
//  Users.swift
//  bulletinboard
//
//  Created by bhavik on 13/12/18.
//  Copyright © 2018 bhavik. All rights reserved.
//

import Foundation
class Users{
    var id : String?
    var name: String?
    var email: String?
    init(id:String,name: String,email: String){
        self.id = id
        self.name = name
        self.email = email
    }
}
