//
//  DatabaseManager.swift
//  Messenger_2
//
//  Created by Goyal, Pratik on 24/02/21.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
}


// MARK: - Account Mgmt

extension DatabaseManager{
    
    public func userExistsWithEmail(with email : String,
                                    completion : @escaping ((Bool) -> Void)){
        database.child(email).observeSingleEvent(of: .value, with: {snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            
            completion(true)
        })
    }
    
    
    /// Inserts new user to database
    public func insertUser(with user : ChatAppUser){
        database.child(user.emailAddress).setValue([
            "first_name" : user.firstName,
            "last_name" : user.lastName
        ])
    }
}

struct ChatAppUser {
    let firstName : String
    let lastName : String
    let emailAddress : String
    //    let profilePictureUrl : String
}
