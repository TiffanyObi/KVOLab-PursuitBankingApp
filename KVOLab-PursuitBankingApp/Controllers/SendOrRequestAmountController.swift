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
    var db  = DatabaseService()
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(resignTextfeilds))
        return gesture
    }()
    
    private var contacts = [Contact](){
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    var selectedContact: Contact!
    var dollarAmount: Double!
    
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
        configurePickerView()
        selectedContact = contacts.first
        view.addGestureRecognizer(tapGesture)
    }
    
    private func configurePickerView() {
        pickerView.dataSource = self
        pickerView.delegate = self
        amountTextField.delegate = self
    }
    
    @objc private func resignTextfeilds(){
        amountTextField.resignFirstResponder()
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        guard !dollarAmount.isZero else {return}
        let balance = (selectedContact.accountBalance + dollarAmount)
        db.addToCurrentUserAccountHistory(contact: selectedContact, balance: "- \(dollarAmount ?? 0.0)") { [weak self] (result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case.success:
                self?.db.updateContactBalance(contact: self!.selectedContact, balance: balance, completion: { (result) in
                    switch result {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .success:
                        self?.amountTextField.text = ""
                        self?.showAlert(title: "Done!", message: "Transaction Completed")
                    }
                })
            }
        }
    }
    
    @IBAction func requestButtonPressed(_ sender: UIButton) {
        guard !dollarAmount.isZero else {return}
        let balance = (selectedContact.accountBalance - dollarAmount)
        
        db.addToCurrentUserAccountHistory(contact: selectedContact, balance: "+ \(dollarAmount ?? 0.0)") { [weak self](result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case.success:
                self?.db.updateContactBalance(contact: self!.selectedContact, balance: balance, completion: { (result) in
                    switch result {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .success:
                        self?.amountTextField.text = ""
                        self?.showAlert(title: "Done!", message: "Transaction Completed")
                        
                    }
                })
            }
        }
    }
}

extension SendOrRequestAmountController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return contacts.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return contacts[row].name
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedContact = contacts[row]
    }
}

extension SendOrRequestAmountController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        let dollarString = Int(textField.text ?? "0")
        
        dollarAmount = Double(dollarString!)
    }
}
