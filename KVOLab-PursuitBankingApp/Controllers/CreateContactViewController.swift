//
//  CreateContactViewController.swift
//  KVOLab-PursuitBankingApp
//
//  Created by Tiffany Obi on 4/8/20.
//  Copyright © 2020 Tiffany Obi. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth


class CreateContactViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var contactNameTextfield: UITextField!
    
    @IBOutlet weak var contactPhoneNumberTextfield: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var topContraints: NSLayoutConstraint!
    private var constraint :CGFloat = 0
    var dataBase = DatabaseService()
    var contacts = [Contact]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var keyboardIsVisible = false
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(keyboardWillHide(_:)))
        return gesture
    }()
    
    private var listener: ListenerRegistration?
    
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
       configureTableView()
        configureTextfield()
        registerForKeyboardNotifications()
        view.addGestureRecognizer(tapGesture)
    }

    override func viewWillDisappear(_ animated: Bool) {
    unregisterForKeyboardNotifications()
    }
    
    private func configureTableView(){
        tableView.dataSource = self
        tableView.delegate = self
    }
    private func configureTextfield(){
        contactNameTextfield.delegate = self
        contactPhoneNumberTextfield.delegate = self
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let accountBalance = AccountBalance().balance
        let newContact = Contact(name: contactNameTextfield.text ?? "no name", number: contactPhoneNumberTextfield.text ?? "555-5555", accountBalance: accountBalance, contactID: UUID().uuidString)
        contacts.append(newContact)
//        newContact.accountBalance
        dataBase.addContactForUser(contact: newContact) { [weak self](result) in
            switch result {
            case.failure(let error):
                self?.showAlert(title: "Error Saving Contact", message: error.localizedDescription)
            case .success(true):
                self?.showAlert(title: "Contact Saved", message: nil)
            case .success(false):
                print("Success case that reads false. ")
            }
        }
        
        contactNameTextfield.text = ""
        contactPhoneNumberTextfield.text = ""
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    private func unregisterForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        print("keyboardWillShow")
        
        guard let keyboardFrame = notification.userInfo?["UIKeyboardFrameBeginUserInfoKey"] as? CGRect else {
            return
        }
        moveKeyboardUp(keyboardFrame.size.height)
    }
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        contactPhoneNumberTextfield.resignFirstResponder()
        contactNameTextfield.resignFirstResponder()
        resetUI()
    }
    func moveKeyboardUp(_ height: CGFloat) {
        if keyboardIsVisible {return}
        constraint = topContraints.constant
       topContraints.constant -= (height)
        UIView.animate(withDuration: 1.0, delay: 0.2, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        keyboardIsVisible = true
    }
    func resetUI() {
       topContraints.constant = constraint
        keyboardIsVisible = false
    }

}

extension CreateContactViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        
        let contact = contacts[indexPath.row]
        
        cell.textLabel?.text = contact.name
        cell.detailTextLabel?.text = "\(contact.accountBalance)"
        return cell
    }
    
    
}

extension CreateContactViewController:UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let nameText = contactNameTextfield.text,
            !nameText.isEmpty,
            let numberText = contactPhoneNumberTextfield.text,
            !numberText.isEmpty
        else {return}
}
}
