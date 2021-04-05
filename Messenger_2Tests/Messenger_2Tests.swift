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
    var loginStatus: Bool = false
    
    init(email : String, password : String) {
        self.email = email
        self.password = password
    }
    
    func login(email: String, password: String) {
        guard email == "", password == "" else {
            self.loginStatus = true
            return
        }
        guard loginStatus == false else {
            self.altertUserLoginSuccess()
            return
        }
        self.altertUserLoginError()
        return
    }
    
    func altertUserLoginSuccess() {
        print("Login Success")
    }
    
    func altertUserLoginError() {
        print("Login Error")
    }
}

class Messenger_2Tests: XCTestCase {
    private var loginService : LoginService!
    
    func testLogin(){
        let service1 = MockedLogin(email: "pratik@gmail.com", password: "1234")
        service1.login(email: service1.email, password: service1.password)
        XCTAssertTrue(service1.loginStatus)
        let service2 = MockedLogin(email: "", password: "")
        service1.login(email: service2.email, password: service1.password)
        XCTAssertFalse(service2.loginStatus)
        
    }
}
