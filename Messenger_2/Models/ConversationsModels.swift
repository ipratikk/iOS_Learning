//
//  ConversationsModels.swift
//  Messenger_2
//
//  Created by Goyal, Pratik on 04/03/21.
//

import Foundation

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
