//
//  Review.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 31/03/2025.
//

import Foundation
import FirebaseFirestore


struct Review: Identifiable, Codable {
    @DocumentID var id: String?
    var chatID: String
    var jobID: String
    var reviewerEmail: String
    var revieweeEmail: String
    var rating: Int
    var feedback: String
    var timestamp: Date                     

    enum CodingKeys: String, CodingKey {
        case id, jobID, reviewerEmail, revieweeEmail, rating, feedback, timestamp, chatID
    }
}


