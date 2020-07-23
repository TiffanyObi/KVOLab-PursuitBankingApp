//
//  DatabaseService.swift
//  KVOLab-PursuitBankingApp
//
//  Created by Tiffany Obi on 4/8/20.
//  Copyright © 2020 Tiffany Obi. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class DatabaseService {
    static let users = "userCollection"
    static let contacts = "contactsCollection"
    static let accountHistory = "accHistCollection"
    
    let database = Firestore.firestore()
    
     public func createDatabaseUser(authDataResult: AuthDataResult, completion: @escaping (Result<Bool,Error>) -> ()){
            
            guard let email = authDataResult.user.email else {return}
            database.collection(DatabaseService.users).document(authDataResult.user.uid).setData(["email" : email, "createdDate":Timestamp(date: Date()),"userId": authDataResult.user.uid]) { (error) in
                
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(true))
                }
            }
            
        }
    
      func addContactForUser(contact: Contact, completion: @escaping (Result<Bool, Error>) -> ()){
            guard let user = Auth.auth().currentUser else { return }
        database.collection(DatabaseService.users).document(user.uid).collection(DatabaseService.contacts).document(contact.contactID).setData(["name":contact.name, "number":contact.number, "accountBalance":contact.accountBalance, "contactID": contact.contactID]) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true ))
            }
        }
    }
    
    func addToCurrentUserAccountHistory(contact:Contact, balance:String, completion:@escaping (Result<Bool,Error>) -> ()){
        guard let user = Auth.auth().currentUser else {return}
        
        database.collection(DatabaseService.users).document(user.uid).collection(DatabaseService.accountHistory).document().setData(["contactID" : "\(contact.contactID)", "contactName" : "\(contact.name)","transaction" : balance]) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }

    
    func updateContactBalance(contact:Contact, balance:Double, completion:@escaping(Result<Bool,Error>)->()){
        
        guard let user = Auth.auth().currentUser else { return }
        database.collection(DatabaseService.users).document(user.uid).collection(DatabaseService.contacts).document(contact.contactID).updateData(["accountBalance" : balance]) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
        
                completion(.success(true))
            }
        }
    }
    
   
//    public func removeEventFromFavorites(event: Event, completion: @escaping (Result<Bool,Error>) ->()) {
//
//          guard let user = Auth.auth().currentUser else { return }
//
//          database.collection(DatabaseService.usersCollection).document(user.uid).collection(DatabaseService.favoritedEvents).document(event.id).delete() {
//              (error) in
//              if let error = error {
//                  completion(.failure(error))
//              } else {
//                  completion(.success(true))
//              }
//          }
//      }

}
