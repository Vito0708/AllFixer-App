//
//  ReviewPopupView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 31/03/2025.
//

import SwiftUI
import FirebaseFirestore

struct ReviewPopupView: View {
    @Environment(\.dismiss) var dismiss

    @State private var starRating: Int = 0
    @State private var feedback: String = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    let chatID: String
    let reviewerEmail: String
    let revieweeEmail: String
    let jobID: String
    let onSubmit: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Leave a Review")
                    .font(.title2)
                    .fontWeight(.bold)

                //  Star rating
                HStack {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= starRating ? "star.fill" : "star")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.yellow)
                            .onTapGesture {
                                starRating = star
                            }
                    }
                }

                //  Feedback
                TextField("Write something...", text: $feedback)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                //  Error message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                //  Submit Button
                Button(action: submitReview) {
                    if isSubmitting {
                        ProgressView()
                    } else {
                        Text("Submit Review")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Review")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    func submitReview() {
        guard starRating > 0 else {
            errorMessage = "Please select a star rating."
            return
        }

        isSubmitting = true
        let db = Firestore.firestore()

        let review = Review(
            chatID: chatID,
            jobID: jobID,
            reviewerEmail: reviewerEmail,
            revieweeEmail: revieweeEmail,
            rating: starRating,
            feedback: feedback,
            timestamp: Date()
        )

        do {
            _ = try db.collection("reviews").addDocument(from: review)
            onSubmit()
            dismiss()
        } catch {
            self.errorMessage = "Failed to submit review: \(error.localizedDescription)"
        }

        isSubmitting = false
    }
}



