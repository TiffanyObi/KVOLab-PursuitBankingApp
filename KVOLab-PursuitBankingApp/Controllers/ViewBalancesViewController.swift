//
//  ViewBalancesViewController.swift
//  KVOLab-PursuitBankingApp
//
//  Created by Tiffany Obi on 4/14/20.
//  Copyright © 2020 Tiffany Obi. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ViewBalancesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var listener: ListenerRegistration?
    
    
    var transactions = [Transactions](){
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
          guard let user = Auth.auth().currentUser else { return }
          
        listener = Firestore.firestore().collection(DatabaseService.users).document(user.uid).collection(DatabaseService.accountHistory).addSnapshotListener({ [weak self](snapshot, error) in
                   if let error = error {
                       DispatchQueue.main.async {
                           self?.showAlert(title: "Firestore Error (Cannot Retrieve Data)", message: "\(error.localizedDescription)")
                       }
                   } else if let snapshot = snapshot {
                       let history = snapshot.documents.map {
                           Transactions($0.data())}
                       self?.transactions = history
                   }
               })
      }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }

    private func setUpTableView(){
        tableView.dataSource = self
        tableView.delegate = self
    }

}

extension ViewBalancesViewController:UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let transactionCell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath) as? TransactionCell else {
            fatalError("could not downcast to TransactionCell()")
        }
        let transaction = transactions[indexPath.row]
        transactionCell.configureCell(transaction: transaction)
 
    return transactionCell
}
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
