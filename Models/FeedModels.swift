//
//  FeedModels.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 21/01/2025.
//

import Foundation
import FirebaseFirestore

struct Job: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var price: Double
    var location: String
    var postedBy: String
    var postedByName: String
    var createdAt: Date
    var latitude: Double
    var longitude: Double
    var jobType: String
    var imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, title, description, price, location, postedBy, postedByName, createdAt, latitude, longitude, jobType, imageUrl
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(price, forKey: .price)
        try container.encode(location, forKey: .location)
        try container.encode(postedBy, forKey: .postedBy)
        try container.encode(postedByName, forKey: .postedByName)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(jobType, forKey: .jobType)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(Timestamp(date: createdAt), forKey: .createdAt)
    }
}

struct Advert: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var price: Double
    var location: String
    var postedBy: String
    var postedByName: String
    var createdAt: Date
    var latitude: Double
    var longitude: Double
    var jobType: String
    var imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, title, description, price, location, postedBy, postedByName, createdAt, latitude, longitude, jobType, imageUrl
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(price, forKey: .price)
        try container.encode(location, forKey: .location)
        try container.encode(postedBy, forKey: .postedBy)
        try container.encode(postedByName, forKey: .postedByName)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(jobType, forKey: .jobType)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(Timestamp(date: createdAt), forKey: .createdAt)
    }
}
