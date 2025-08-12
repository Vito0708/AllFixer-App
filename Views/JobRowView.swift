//
//  JobRowView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 26/02/2025.
//

import SwiftUI

struct JobRowView: View {
    let job: Job
    var isPopup: Bool = false

    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var feedViewModel: FeedViewModel

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(job.title)
                    .font(.headline)

                Spacer()

                if !isPopup {
                    Button(action: {
                        toggleSave()
                    }) {
                        Image(systemName: authViewModel.isJobSaved(jobID: job.id ?? "") ? "star.fill" : "star")
                            .foregroundColor(authViewModel.isJobSaved(jobID: job.id ?? "") ? .yellow : .gray)
                            .padding()
                    }
                }
            }

            Text(job.description)
                .font(.subheadline)
                .foregroundColor(.gray)

            Text("£\(job.price, specifier: "%.2f")")
                .font(.body)
                .foregroundColor(.blue)

            Text("Location: \(job.location)")
                .font(.footnote)
                .foregroundColor(.secondary)

            Text("Job Type: \(job.jobType)")
                .font(.footnote)
                .foregroundColor(.purple)

            Text("Posted by: \(job.postedByName)")
                .font(.footnote)
                .foregroundColor(.gray)

            
            if let rating = feedViewModel.averageRating(for: job.postedBy) {
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= Int(round(rating)) ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                    }
                    Text("(\(String(format: "%.1f", rating)))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }

    private func toggleSave() {
        if let jobID = job.id {
            if authViewModel.isJobSaved(jobID: jobID) {
                authViewModel.removeSavedJob(jobID: jobID)
            } else {
                authViewModel.saveJob(jobID: jobID)
            }
        }
    }
}


