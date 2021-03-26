//
//  ProfileViewModel.swift
//  Messenger_2
//
//  Created by Goyal, Pratik on 04/03/21.
//

import Foundation

enum ProfileViewModelType {
    case info, logout
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}
