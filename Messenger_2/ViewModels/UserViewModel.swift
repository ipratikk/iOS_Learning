//
//  UserViewModel.swift
//  Messenger_2
//
//  Created by Goyal, Pratik on 09/04/21.
//

import Foundation

import Foundation

public struct UserViewModel {
    
    private let user : User
    
    public var name : String {
        return user.name
    }
    
    public var email : String {
        return user.email
    }
    
    public var displayText : String {
        return user.name + " \n " + user.email + " \n "
    }
    
    init(user : User) {
        self.user = user
//        print("Inside UserViewModel \(self.user)")
    }
}

