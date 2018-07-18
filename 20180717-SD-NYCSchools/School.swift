//
//  Schools.swift
//  20180717-SD-NYCSchools
//
//  Created by Sean Donato on 7/17/18.
//  Copyright © 2018 Sean Donato. All rights reserved.
//

import Foundation

struct School {
    
    let name: String
//    let email: String
//    let phone: String
//    let description: String
    init(dictionary: [String: Any]) {
        self.name = dictionary["school_name"] as? String ?? ""
       // self.phone = dictionary["phoneNo"] as? String ?? ""
    }

}
