//
//  AdminVerifyRequestsView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 23/03/2025.
//



import SwiftUI
import FirebaseFirestore

struct AdminVerifyRequestsView: View {
    @State private var unverifiedTradesmen: [User] = []
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading verification requests...")
                        .padding()
                } else if unverifiedTradesmen.isEmpty {
                    Text("No pending verification requests.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(unverifiedTradesmen) { user in
                        NavigationLink(destination: AdminVerifyTradesmanView(user: user)) {
                            VStack(alignment: .leading) {
                                Text(user.name)
                                    .font(.headline)
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Verification Requests")
            .onAppear {
                fetchUnverifiedTradesmen()
            }
        }
    }

    // Fetch unverified tradesmen from Firestore
    func fetchUnverifiedTradesmen() {
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("userType", isEqualTo: "Tradesman")
            .whereField("isVerified", isEqualTo: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching tradesmen: \(error.localizedDescription)")
                    self.isLoading = false
                    return
                }

                guard let documents = snapshot?.documents else {
                    self.isLoading = false
                    return
                }

                self.unverifiedTradesmen = documents.compactMap { doc in
                    let data = doc.data()
                    return User(
                        id: doc.documentID,
                        name: data["name"] as? String ?? "Unknown",
                        email: data["email"] as? String ?? "",
                        userType: data["userType"] as? String ?? "Tradesman",
                        latitude: data["latitude"] as? Double ?? 0.0,
                        longitude: data["longitude"] as? Double ?? 0.0,
                        savedJobs: data["savedJobs"] as? [String] ?? [],
                        savedAdverts: data["savedAdverts"] as? [String] ?? [],
                        displayName: data["displayName"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        location: data["location"] as? String,
                        jobImages: data["jobImages"] as? [String],
                        isVerified: false
                    )
                }

                self.isLoading = false
            }
    }
}
