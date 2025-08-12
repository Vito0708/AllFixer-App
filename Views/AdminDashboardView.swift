//
//  AdminDashboardView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 22/03/2025.
//

import SwiftUI
import FirebaseFirestore

struct AdminDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var jobs: [Job] = []
    @State private var adverts: [Advert] = []
    @State private var pendingTradesmen: [User] = []
    @State private var showVerifyView: Bool = false
    @State private var selectedUserForVerification: User?

    let primaryColor = Color(hex: "#00A7E1")

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Admin Dashboard")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(primaryColor)

                    // Pending Tradesmen Section
                    sectionHeader("Pending Tradesmen Applications")

                    if pendingTradesmen.isEmpty {
                        emptyState("No pending applications.")
                    } else {
                        ForEach(pendingTradesmen, id: \.id) { user in
                            Button(action: {
                                selectedUserForVerification = user
                                showVerifyView = true
                            }) {
                                HStack {
                                    Text(user.name)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text("Pending")
                                        .foregroundColor(.orange)
                                        .font(.subheadline)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .gray.opacity(0.2), radius: 3, x: 0, y: 2)
                            }
                        }
                    }

                    Divider()

                    //  Posted Jobs
                    sectionHeader("All Posted Jobs")

                    if jobs.isEmpty {
                        emptyState("No jobs available.")
                    } else {
                        ForEach(jobs, id: \.id) { job in
                            adminPostCard(title: job.title, description: job.description) {
                                deleteJob(job)
                            }
                        }
                    }

                    Divider()

                    //  Posted Adverts
                    sectionHeader("All Posted Services")

                    if adverts.isEmpty {
                        emptyState("No adverts available.")
                    } else {
                        ForEach(adverts, id: \.id) { advert in
                            adminPostCard(title: advert.title, description: advert.description) {
                                deleteAdvert(advert)
                            }
                        }
                    }
                }
                .padding()
            }
            .onAppear {
                fetchAllJobs()
                fetchAllAdverts()
                fetchPendingTradesmen()
            }
            .sheet(isPresented: $showVerifyView) {
                if let user = selectedUserForVerification {
                    AdminVerifyTradesmanView(user: user)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    

    func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(primaryColor)
            Spacer()
        }
    }

    func emptyState(_ message: String) -> some View {
        Text(message)
            .foregroundColor(.gray)
            .font(.subheadline)
            .padding(.vertical, 8)
    }

    func adminPostCard(title: String, description: String, onDelete: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(3)

            Button(action: onDelete) {
                Text("Delete")
                    .font(.footnote)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 3, x: 0, y: 2)
    }

    

    func fetchAllJobs() {
        Firestore.firestore().collection("jobs").getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                self.jobs = documents.compactMap {
                    try? $0.data(as: Job.self)
                }
            }
        }
    }

    func fetchAllAdverts() {
        Firestore.firestore().collection("adverts").getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                self.adverts = documents.compactMap {
                    try? $0.data(as: Advert.self)
                }
            }
        }
    }

    func fetchPendingTradesmen() {
        Firestore.firestore().collection("users")
            .whereField("userType", isEqualTo: "Tradesman")
            .whereField("isVerified", isEqualTo: false)
            .getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    self.pendingTradesmen = documents.compactMap {
                        try? $0.data(as: User.self)
                    }
                }
            }
    }

    func deleteJob(_ job: Job) {
        guard let jobID = job.id else { return }
        Firestore.firestore().collection("jobs").document(jobID).delete()
    }

    func deleteAdvert(_ advert: Advert) {
        guard let advertID = advert.id else { return }
        Firestore.firestore().collection("adverts").document(advertID).delete()
    }
}


