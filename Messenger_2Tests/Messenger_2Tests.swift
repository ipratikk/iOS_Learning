//
//  Messenger_2Tests.swift
//  Messenger_2Tests
//
//  Created by Goyal, Pratik on 05/04/21.
//

import XCTest
@testable import Messenger_2

final class MockedLogin : LoginService {
    var email: String
    var password: String
    
    init(email : String, password : String) {
        self.email = email
        self.password = password
    }
    
    func login(email: String, password: String, completionHandler: @escaping (Bool) -> Void) {
        guard email == "", password == "" else {
            self.altertUserLoginSuccess(){ success in
                completionHandler(true)
                return
            }
            return
        }
        self.altertUserLoginError()
        completionHandler(false)
        return
    }
    
    func altertUserLoginSuccess(completion: @escaping (Bool) -> Void) {
        print("Login Success")
    }
    
    func altertUserLoginError() {
        print("Login Error")
    }
}

final class MockedChats : UIViewController, ChatsViewService  {
    var isNewConversation: Bool = false
    
    var otherUserEmail: String = ""
    
    var conversationID: String? = ""
    
    func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        
    }
}

class Messenger_2Tests: XCTestCase {
    private var loginService : LoginService!
    
    func testLogin(){
        let service1 = MockedLogin(email: "pratik@gmail.com", password: "1234")
        service1.login(email: service1.email, password: service1.password) { status in
            XCTAssertTrue(status)
        }
        let service2 = MockedLogin(email: "", password: "")
        service1.login(email: service2.email, password: service1.password) { status in
            XCTAssertFalse(status)
        }
    }
}
