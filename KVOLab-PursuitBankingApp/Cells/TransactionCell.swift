//
//  TransactionCell.swift
//  KVOLab-PursuitBankingApp
//
//  Created by Tiffany Obi on 7/23/20.
//  Copyright © 2020 Tiffany Obi. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell {

    @IBOutlet weak var contactImageView: UIImageView!
    
    @IBOutlet weak var contactNameLabel: UILabel!
    
    @IBOutlet weak var transactionLabel: UILabel!
    
    public func configureCell(transaction:Transactions){
        contactNameLabel.text = transaction.contactName
        
        transactionLabel.text = transaction.transaction
    }
    
    
}
