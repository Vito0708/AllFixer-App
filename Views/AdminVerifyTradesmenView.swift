//
//  AdminVerifyTradesmenView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 22/03/2025.
//

import SwiftUI
import FirebaseFirestore
import SDWebImageSwiftUI

struct AdminVerifyTradesmanView: View {
    let user: User
    @Environment(\.presentationMode) var presentationMode

    @State private var certificateURL: String = ""
    @State private var idURL: String = ""
    @State private var selfieURL: String = ""
    @State private var loading: Bool = true
    @State private var isProcessing: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Review Documents")
                    .font(.title2)
                    .bold()

                if loading {
                    ProgressView("Loading images...")
                        .padding()
                } else {
                    VStack(spacing: 15) {
                        DocumentSectionView(title: "Certificate", imageUrl: certificateURL)
                        DocumentSectionView(title: "ID", imageUrl: idURL)
                        DocumentSectionView(title: "Selfie", imageUrl: selfieURL)
                    }
                    .padding(.horizontal)

                    if isProcessing {
                        ProgressView("Processing...")
                            .padding()
                    } else {
                        VStack(spacing: 15) {
                            HStack(spacing: 20) {
                                Button(action: approveTradesman) {
                                    Text("Approve")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }

                                Button(action: disapproveTradesman) {
                                    Text("Disapprove")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.orange)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }

                            Button(role: .destructive) {
                                deleteUser(userID: user.id ?? "")
                            } label: {
                                Text("Ban & Delete User")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red.opacity(0.9))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer(minLength: 30)
            }
            .padding()
            .navigationTitle("Verification: \(user.name)")
            .onAppear(perform: loadDocuments)
        }
    }

    // Load image URLs from Firestore
    func loadDocuments() {
        let db = Firestore.firestore()
        db.collection("users").document(user.id ?? "").getDocument { document, error in
            if let data = document?.data() {
                certificateURL = data["certificateUrl"] as? String ?? ""
                idURL = data["idUrl"] as? String ?? ""
                selfieURL = data["selfieUrl"] as? String ?? ""
            }
            loading = false
        }
    }

    // Approve the tradesman
    func approveTradesman() {
        isProcessing = true
        Firestore.firestore().collection("users").document(user.id ?? "").updateData([
            "isVerified": true
        ]) { error in
            isProcessing = false
            if let error = error {
                print("❌ Error approving user: \(error.localizedDescription)")
            } else {
                print("✅ User approved")
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    // Disapprove the tradesman
    func disapproveTradesman() {
        isProcessing = true
        Firestore.firestore().collection("users").document(user.id ?? "").updateData([
            "isVerified": false
        ]) { error in
            isProcessing = false
            if let error = error {
                print("❌ Error disapproving user: \(error.localizedDescription)")
            } else {
                print("✅ User disapproved")
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    // Ban user by deleting their account from Firestore
    func deleteUser(userID: String) {
        isProcessing = true
        Firestore.firestore().collection("users").document(userID).delete { error in
            isProcessing = false
            if let error = error {
                print("❌ Error deleting user: \(error.localizedDescription)")
            } else {
                print("✅ User account deleted")
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct DocumentSectionView: View {
    let title: String
    let imageUrl: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)

            if imageUrl.isEmpty {
                Text("No image uploaded")
                    .foregroundColor(.gray)
                    .font(.caption)
            } else {
                WebImage(url: URL(string: imageUrl))
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .cornerRadius(8)
            }
        }
    }
}
