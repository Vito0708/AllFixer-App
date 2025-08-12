//
//  ChatModels.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 20/03/2025.
//

import Foundation
import FirebaseFirestore


struct Chat: Identifiable, Codable {
    @DocumentID var id: String?
    var participants: [String]
    var lastMessage: String
    var lastMessageTimestamp: Date

    
    var jobAcceptedBy: [String]?
    var bothAccepted: Bool?
    var jobFinishedBy: [String]?
    var jobCompleted: Bool?

    enum CodingKeys: String, CodingKey {
        case id, participants, lastMessage, lastMessageTimestamp, jobAcceptedBy, bothAccepted, jobFinishedBy, jobCompleted
    }
}


struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var senderID: String
    var text: String
    var timestamp: Date          

    enum CodingKeys: String, CodingKey {
        case id, senderID, text, timestamp
    }
}


