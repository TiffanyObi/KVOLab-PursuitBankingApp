//
//  SendOrRequestAmountController.swift
//  KVOLab-PursuitBankingApp
//
//  Created by Tiffany Obi on 4/14/20.
//  Copyright © 2020 Tiffany Obi. All rights reserved.
//

import UIKit
import FirebaseAuth
import  FirebaseFirestore

class SendOrRequestAmountController: UIViewController {
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var requestButton: UIButton!
    
    
    private var listener: ListenerRegistration?
    private var contacts = [Contact](){
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let user = Auth.auth().currentUser else { return }
        print(user.email ?? "no email")
            
            listener = Firestore.firestore().collection(DatabaseService.users).document(user.uid).collection(DatabaseService.contacts).addSnapshotListener({ [weak self](snapshot, error) in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Firestore Error (Cannot Retrieve Data)", message: "\(error.localizedDescription)")
                    }
                } else if let snapshot = snapshot {
                    let savedContacts = snapshot.documents.map {
                        Contact($0.data())}
                    self?.contacts = savedContacts
                }
            })
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    

    @IBAction func sendButtonPressed(_ sender: UIButton) {
        
    }
    
    
    @IBAction func requestButtonPressed(_ sender: UIButton) {
        
    }
    
}
