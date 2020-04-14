//
//  LoginViewController.swift
//  KVOLab-PursuitBankingApp
//
//  Created by Tiffany Obi on 4/8/20.
//  Copyright © 2020 Tiffany Obi. All rights reserved.
//

import UIKit
import FirebaseAuth

enum AccountState {
    case existingUser
    case newUser
}
class LoginViewController: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var emailTextfield: UITextField!
    
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var statusButton: UIButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    private var constraint:CGFloat = 0
    private var accountState: AccountState = .existingUser
       
       private var authSession = AuthenticationSesson()
       private var dataBaseService = DatabaseService()
    
     private var keyboardIsVisible = false
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(keyboardWillHide(_:)))
        return gesture
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardNotifications()
        view.addGestureRecognizer(tapGesture)
        clearErrorLabel()
        messageLabel.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        unregisterForKeyboardNotifications()
    }

    @IBAction func signInButtonPressed(_ sender: UIButton) {
        guard let email = emailTextfield.text,
                !email.isEmpty,
                let password = passwordTextfield.text,
                !password.isEmpty else {
                    print("missing feilds")
                    return
            }
            continueLoginFlow(email: email, password: password)
        }
        private func continueLoginFlow(email:String,password:String) {
            if accountState == .existingUser {
                authSession.signInExistingUsingUser(email: email, password: password) { [weak self](result) in
                    switch result {
                    case .failure(let error):
                        print(error)
                        DispatchQueue.main.async {
                            self?.messageLabel.isHidden = false
                            self?.messageLabel.text = "Incorrect Login"
                            self?.messageLabel.textColor = .systemRed
                        }
                    case .success:
                        DispatchQueue.main.async {
                            //navigate to main view
                            self?.navigateToMainView()
                        }
                    }
                }
            } else {
                authSession.creatNewUser(email: email, password: password) { [weak self] (result) in
                    switch result {
                    case .failure(let error):
                        print(error)
                        DispatchQueue.main.async {
                            self?.messageLabel.isHidden = false
                            self?.messageLabel.text = "Error Signing Up"
                            self?.messageLabel.textColor = .systemRed
                        }
                    case .success(let authDataResult):
                        self?.createDatabaseUser(authDataResult: authDataResult)
                }
            }
        }
    }
    private func createDatabaseUser(authDataResult: AuthDataResult) {
        dataBaseService.createDatabaseUser(authDataResult: authDataResult) {[weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Account Error", message: error.localizedDescription)
                }
            case .success:
                self?.navigateToMainView()
            }
        }
    }
    private func navigateToMainView() {
        UIViewController.showViewController(storyboardName: "Main", viewControllerID: "TabBar")
    }
    private func clearErrorLabel() {
        messageLabel.text = ""
    }

    @IBAction func statusButtonPressed(_ sender: UIButton) {
        accountState = accountState == .existingUser ? .newUser : .existingUser
               if accountState == .existingUser {
                   signInButton.setTitle("Login", for: .normal)
                   statusLabel.text = "Don't have an account ? Click"
                   statusButton.setTitle("SIGNUP", for: .normal)
               } else {
                   signInButton.setTitle("Sign Up", for: .normal)
                   statusLabel.text = "Already have an account ?"
                   statusButton.setTitle("LOGIN", for: .normal)
               }
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
           emailTextfield.resignFirstResponder()
           passwordTextfield.resignFirstResponder()
           resetUI()
       }
      private func moveKeyboardUp(_ height: CGFloat) {
           if keyboardIsVisible {return}
           constraint = bottomConstraint.constant
           bottomConstraint.constant -= (height)
           UIView.animate(withDuration: 1.0, delay: 0.2, options: .curveEaseIn, animations: {
               self.view.layoutIfNeeded()
           }, completion: nil)
           keyboardIsVisible = true
       }
      private func resetUI() {
           bottomConstraint.constant = constraint
           keyboardIsVisible = false
       }
}
