//
//  AgreementStatus.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 25/03/2025.
//

import Foundation

struct AgreementStatus: Identifiable, Codable {
    var id: String
    var chatID: String
    var senderID: String
    var receiverID: String
    var senderAccepted: Bool
    var receiverAccepted: Bool
    var timestamp: Date
}
