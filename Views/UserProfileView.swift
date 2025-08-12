//
//  UserProfileView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 28/03/2025.
//

import SwiftUI
import FirebaseFirestore

struct UserProfileView: View {
    let userEmail: String

    @State private var user: User?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var contactInfo: String = ""  // Local-only contact field

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading profile...")
            } else if let user = user {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        //  Display Name
                        Text(user.displayName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color.blue)

                        //  About Me / Description
                        if let description = user.description, !description.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("About Me")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Text(description)
                                    .font(.body)
                            }
                        }

                        //  County / Location
                        if let location = user.location, !location.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("County")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Text(location)
                                    .font(.body)
                            }
                        }

                        //  Contact (Local-only)
                        if !contactInfo.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Contact")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Text(contactInfo)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(8)
                            }
                        }

                        //  Gallery (fix)
                        if let images = user.jobImages, !images.isEmpty {
                            Text(user.userType.lowercased() == "tradesman" ? "Previous Work" : "Work Needed")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.top)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(images, id: \.self) { url in
                                        AsyncImage(url: URL(string: url)) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 150, height: 150)
                                                .clipped()
                                                .cornerRadius(10)
                                        } placeholder: {
                                            ProgressView()
                                                .frame(width: 150, height: 150)
                                        }
                                    }
                                }
                                .padding(.vertical)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    .padding()
                }
            } else if let error = errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            }
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .navigationTitle("Profile")
        .onAppear {
            fetchUser()
        }
    }

    private func fetchUser() {
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("email", isEqualTo: userEmail)
            .getDocuments { snapshot, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    return
                }

                guard let document = snapshot?.documents.first else {
                    self.errorMessage = "User not found."
                    self.isLoading = false
                    return
                }

                do {
                    self.user = try document.data(as: User.self)
                    self.isLoading = false
                } catch {
                    self.errorMessage = "Failed to decode user data."
                    self.isLoading = false
                }
            }
    }
}
