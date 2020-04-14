//
//  UIViewController+Alerts.swift
//  KVOLab-PursuitBankingApp
//
//  Created by Tiffany Obi on 4/8/20.
//  Copyright © 2020 Tiffany Obi. All rights reserved.
//

import UIKit

extension UIViewController {
    public func showAlert(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
    
        present(alertController, animated: true)
    }
}
