//
//  Questions.swift
//  bulletinboard
//
//  Created by bhavik on 11/12/18.
//  Copyright © 2018 bhavik. All rights reserved.
//

import Foundation
class Questions{
    
    var question:  String?
    var category: String?
    var city: String?
    init(question: String,category: String,city: String) {
    
        self.question = question
        self.category = category
        self.city = city
}
}
