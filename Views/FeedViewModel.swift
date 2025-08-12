//
//  FeedViewModel.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 28/02/2025.
//


import SwiftUI
import FirebaseFirestore
import CoreLocation

class FeedViewModel: ObservableObject {
    @Published var jobs: [Job] = []
    @Published var adverts: [Advert] = []
    @Published var averageRatings: [String: Double] = [:]
    @Published var userLocation: CLLocation?
    @Published var selectedJobType: String? = nil
    @Published var selectedSortOption: SortOption = .priceLowToHigh
    @Published var selectedPostID: String? = nil
    @Published var selectedChatUserID: String? = nil

    enum SortOption {
        case priceLowToHigh, priceHighToLow, distance
    }

    init(userType: String, currentUserEmail: String?) {
        fetchData(for: userType, currentUserEmail: currentUserEmail)
        fetchAllAverageRatings()
    }

    func fetchData(for userType: String, currentUserEmail: String?) {
        let db = Firestore.firestore()

        if userType == "Tradesman" {
            db.collection("jobs")
                .order(by: "createdAt", descending: true)
                .addSnapshotListener { [weak self] snapshot, error in
                    guard let self = self else { return }

                    if let snapshot = snapshot {
                        DispatchQueue.main.async {
                            self.jobs = snapshot.documents.compactMap { try? $0.data(as: Job.self) }
                        }
                    }
                }

        } else if userType == "Homeowner" {
            db.collection("adverts")
                .order(by: "createdAt", descending: true)
                .addSnapshotListener { [weak self] snapshot, error in
                    guard let self = self else { return }

                    if let snapshot = snapshot {
                        DispatchQueue.main.async {
                            self.adverts = snapshot.documents.compactMap { try? $0.data(as: Advert.self) }
                        }
                    }
                }

        } else if userType == "Admin" {
            db.collection("jobs")
                .order(by: "createdAt", descending: true)
                .addSnapshotListener { [weak self] snapshot, error in
                    guard let self = self else { return }
                    if let snapshot = snapshot {
                        DispatchQueue.main.async {
                            self.jobs = snapshot.documents.compactMap { try? $0.data(as: Job.self) }
                        }
                    }
                }

            db.collection("adverts")
                .order(by: "createdAt", descending: true)
                .addSnapshotListener { [weak self] snapshot, error in
                    guard let self = self else { return }
                    if let snapshot = snapshot {
                        DispatchQueue.main.async {
                            self.adverts = snapshot.documents.compactMap { try? $0.data(as: Advert.self) }
                        }
                    }
                }
        }
    }

    func sort(by option: SortOption) {
        self.selectedSortOption = option

        switch option {
        case .priceLowToHigh:
            jobs.sort { $0.price < $1.price }
            adverts.sort { $0.price < $1.price }
        case .priceHighToLow:
            jobs.sort { $0.price > $1.price }
            adverts.sort { $0.price > $1.price }
        case .distance:
            sortByDistance()
        }
    }

    func sortByDistance() {
        guard let userLocation = userLocation else { return }

        func calculateDistance(_ location: CLLocation) -> CLLocationDistance {
            return userLocation.distance(from: location)
        }

        jobs.sort {
            let loc1 = CLLocation(latitude: $0.latitude, longitude: $0.longitude)
            let loc2 = CLLocation(latitude: $1.latitude, longitude: $1.longitude)
            return calculateDistance(loc1) < calculateDistance(loc2)
        }

        adverts.sort {
            let loc1 = CLLocation(latitude: $0.latitude, longitude: $0.longitude)
            let loc2 = CLLocation(latitude: $1.latitude, longitude: $1.longitude)
            return calculateDistance(loc1) < calculateDistance(loc2)
        }
    }

    func navigateToPost(postID: String) {
        DispatchQueue.main.async {
            self.selectedPostID = postID
        }
    }

    

    func fetchAllAverageRatings() {
        let db = Firestore.firestore()
        db.collection("reviews").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }

            var ratingsMap: [String: [Int]] = [:]

            for doc in documents {
                if let revieweeEmail = doc.data()["revieweeEmail"] as? String,
                   let rating = doc.data()["rating"] as? Int {
                    ratingsMap[revieweeEmail, default: []].append(rating)
                }
            }

            var averageRatingsResult: [String: Double] = [:]

            for (user, ratings) in ratingsMap {
                let average = Double(ratings.reduce(0, +)) / Double(ratings.count)
                averageRatingsResult[user] = average
            }

            DispatchQueue.main.async {
                self.averageRatings = averageRatingsResult
            }
        }
    }

    

    func averageRating(for email: String) -> Double? {
        return averageRatings[email]
    }
}


