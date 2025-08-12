//
//  AdminPanelView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 22/03/2025.
//

import SwiftUI
import FirebaseFirestore
import SDWebImageSwiftUI

struct AdminPanelView: View {
    @EnvironmentObject var feedViewModel: FeedViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    let primaryColor = Color(hex: "#00A7E1")
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    Text("👨‍💼 Admin Dashboard")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(primaryColor)
                        .padding(.horizontal)

                    // SECTION 1: Jobs
                    VStack(alignment: .leading, spacing: 12) {
                        Text("📋 Jobs Posted by Homeowners")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .padding(.horizontal)

                        ForEach(feedViewModel.jobs, id: \.id) { job in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(job.title)
                                    .font(.headline)
                                    .foregroundColor(primaryColor)

                                Text("📍 \(job.location)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Text("💬 \(job.description)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                Text("💰 £\(String(format: "%.2f", job.price))")
                                    .font(.subheadline)
                                    .foregroundColor(.green)

                                Button(action: {
                                    deletePost(collection: "jobs", documentID: job.id)
                                }) {
                                    Text("Delete")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .padding(.horizontal)
                        }
                    }

                    // SECTION 2: Adverts
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🧰 Adverts Posted by Tradesmen")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .padding(.horizontal)

                        ForEach(feedViewModel.adverts, id: \.id) { advert in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(advert.title)
                                    .font(.headline)
                                    .foregroundColor(primaryColor)

                                Text("📍 \(advert.location)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Text("💬 \(advert.description)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                Text("💰 £\(String(format: "%.2f", advert.price))")
                                    .font(.subheadline)
                                    .foregroundColor(.green)

                                Button(action: {
                                    deletePost(collection: "adverts", documentID: advert.id)
                                }) {
                                    Text("Delete")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }

    //  Delete Posts
    func deletePost(collection: String, documentID: String?) {
        guard let documentID = documentID else { return }
        Firestore.firestore().collection(collection).document(documentID).delete { error in
            if let error = error {
                print("❌ Error deleting \(collection) post: \(error.localizedDescription)")
            } else {
                print("✅ Successfully deleted post in \(collection)")
            }
        }
    }
}
