//
//  Contact.swift
//  KVOLab-PursuitBankingApp
//
//  Created by Tiffany Obi on 4/14/20.
//  Copyright © 2020 Tiffany Obi. All rights reserved.
//

import Foundation

struct Contact {
    let name: String
    let number: String
    var accountBalance: Double
    let contactID: String
   
    
    
    init(name:String, number:String, accountBalance:Double, contactID: String) {
        self.name = name
        self.number = number
        self.accountBalance = accountBalance
        self.contactID = contactID
    }
    
    init(_ dictionary: [String:Any]) {
        self.name = dictionary["name"] as? String ?? "no name"
        self.number = dictionary["number"] as? String ?? "no number"
        self.accountBalance = dictionary["accountBalance"] as? Double
            ?? 0.0
        self.contactID = dictionary["contactID"] as? String ?? ""
    }

    
}

struct Transactions {
    let contactName:String
    let transaction:String
    
    
    init(_ dictionary:[String:Any]) {
        self.contactName = dictionary["contactName"] as? String ?? "no contact name"
        
        self.transaction = dictionary["transaction"] as? String ?? "no transactions"
    }
}
