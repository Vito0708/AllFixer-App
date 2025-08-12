//
//  User.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 28/02/2025.
//

import Foundation
import FirebaseFirestore


struct User: Identifiable, Codable {
    @DocumentID var id: String?

    var name: String
    var email: String
    var userType: String
    var latitude: Double?
    var longitude: Double?
    var savedJobs: [String] = []
    var savedAdverts: [String] = []
    var displayName: String

    
    var description: String? = nil
    var location: String? = nil
    var jobImages: [String]? = nil

    //  Verification
    var isVerified: Bool? = nil
    var certificateImageURL: String? = nil
    var idImageURL: String? = nil
    var selfieImageURL: String? = nil

    //  Legacy field support
    var idUrl: String? = nil
    var selfieUrl: String? = nil

    
    var resolvedIDImageURL: String? {
        return idImageURL ?? idUrl
    }

    var resolvedSelfieImageURL: String? {
        return selfieImageURL ?? selfieUrl
    }
}


