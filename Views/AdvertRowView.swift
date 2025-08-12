//
//  AdvertRowView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 26/02/2025.
//

import SwiftUI

struct AdvertRowView: View {
    let advert: Advert
    var isPopup: Bool = false

    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var feedViewModel: FeedViewModel

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(advert.title)
                    .font(.headline)

                Spacer()

                if !isPopup, let advertID = advert.id {
                    Button(action: {
                        toggleSave(advertID)
                    }) {
                        Image(systemName: authViewModel.isAdvertSaved(advertID: advertID) ? "star.fill" : "star")
                            .foregroundColor(authViewModel.isAdvertSaved(advertID: advertID) ? .yellow : .gray)
                            .padding()
                    }
                }
            }

            Text(advert.description)
                .font(.subheadline)
                .foregroundColor(.gray)

            Text("£\(advert.price, specifier: "%.2f")")
                .font(.body)
                .foregroundColor(.blue)

            Text("Location: \(advert.location)")
                .font(.footnote)
                .foregroundColor(.secondary)

            Text("Service Type: \(advert.jobType)")
                .font(.footnote)
                .foregroundColor(.purple)

            Text("Posted by: \(advert.postedByName)")
                .font(.footnote)
                .foregroundColor(.gray)

            // Average Rating (if available)
            if let rating = feedViewModel.averageRating(for: advert.postedBy) {
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

    private func toggleSave(_ advertID: String) {
        if authViewModel.isAdvertSaved(advertID: advertID) {
            authViewModel.removeSavedAdvert(advertID: advertID)
        } else {
            authViewModel.saveAdvert(advertID: advertID)
        }
    }
}


