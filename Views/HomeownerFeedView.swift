//
//  HomeownerFeedView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 21/01/2025.
//

import SwiftUI
import FirebaseFirestore
import CoreLocation
import SDWebImageSwiftUI

struct HomeownerFeedView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var feedViewModel: FeedViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel

    @State private var showPostView = false
    @State private var selectedSortOption: SortOption = .priceLowToHigh
    @State private var selectedAdvertType: String? = nil
    @State private var expandedPostID: String? = nil
    @State private var navigateToChat = false
    @State private var chatID: String?
    @State private var otherUserID: String?
    @State private var originalAdverts: [Advert] = []
    @State private var searchText: String = ""

    enum SortOption {
        case priceLowToHigh, priceHighToLow, distance
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Job Type Icons
                let allJobTypes = ["All", "Plumbing", "Electrical", "Landscaping", "Heating", "Carpentry", "Painting", "Cleaning", "Roofing", "Tiling"]

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(allJobTypes, id: \.self) { type in
                            Button(action: {
                                selectedAdvertType = (selectedAdvertType == type) ? nil : type
                                applyFilters()
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: iconForJobType(type))
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 28, height: 28)
                                        .foregroundColor(selectedAdvertType == type ? .blue : .gray)

                                    Text(type)
                                        .font(.caption)
                                        .foregroundColor(selectedAdvertType == type ? .blue : .gray)
                                        .lineLimit(1)
                                        .fixedSize()
                                }
                                .frame(width: 70)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 16)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search by title or description...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)

                // Sort Options
                sortingOptions()

                // Upload Button
                Button(action: { showPostView.toggle() }) {
                    Text("Post a Job")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#00A7E1"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                // Job Feed
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(filteredAdverts(), id: \.id) { advert in
                            advertCard(for: advert)
                        }
                    }
                    .padding()
                }
            }
            .sheet(isPresented: $showPostView) {
                PostFormView()
            }
            .background(
                NavigationLink(
                    destination: chatID != nil && otherUserID != nil ?
                        ChatScreen(chatID: chatID!, otherUserID: otherUserID!) : nil,
                    isActive: $navigateToChat
                ) { EmptyView() }
            )
            .onAppear {
                if let userType = authViewModel.user?.userType,
                   let userEmail = authViewModel.user?.email {
                    feedViewModel.fetchData(for: userType, currentUserEmail: userEmail)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.originalAdverts = feedViewModel.adverts
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    private func sortingOptions() -> some View {
        Picker("Sort by", selection: $selectedSortOption) {
            Text("Price: Low to High").tag(SortOption.priceLowToHigh)
            Text("Price: High to Low").tag(SortOption.priceHighToLow)
            Text("Closest Services").tag(SortOption.distance)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
        .onChange(of: selectedSortOption) { _ in sortAdverts() }
    }

    private func filteredAdverts() -> [Advert] {
        let typeFiltered = (selectedAdvertType != nil && selectedAdvertType != "All")
            ? originalAdverts.filter { $0.jobType == selectedAdvertType }
            : originalAdverts

        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return typeFiltered
        } else {
            return typeFiltered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    private func advertCard(for advert: Advert) -> some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(advert.title)
                        .font(.headline)
                    Text("£\(advert.price, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Button(action: {
                    expandedPostID = (expandedPostID == advert.id) ? nil : advert.id
                }) {
                    Image(systemName: expandedPostID == advert.id ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                }
            }
            .padding()

            if expandedPostID == advert.id {
                VStack(alignment: .leading, spacing: 8) {
                    Text(advert.description)
                        .font(.body)
                    Text("Location: \(advert.location)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Job Type: \(advert.jobType)")
                        .font(.subheadline)
                        .foregroundColor(.blue)

                    NavigationLink(destination: UserProfileView(userEmail: advert.postedBy)) {
                        Text("Posted by: \(advert.postedByName)")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .underline()
                    }
                    
                    if let avgRating = feedViewModel.averageRating(for: advert.postedBy) {
                        HStack(spacing: 4) {
                            Text("★")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", avgRating))
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                    }

                    if let imageUrl = advert.imageUrl {
                        WebImage(url: URL(string: imageUrl))
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        startChat(with: advert.postedBy)
                    }) {
                        HStack {
                            Image(systemName: "message.fill")
                            Text("Message")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding(.top, 5)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }

    private func applyFilters() {
        if let selectedType = selectedAdvertType, selectedType != "All" {
            feedViewModel.adverts = originalAdverts.filter { $0.jobType == selectedType }
        } else {
            feedViewModel.adverts = originalAdverts
        }
        sortAdverts()
    }

    private func sortAdverts() {
        switch selectedSortOption {
        case .priceLowToHigh:
            feedViewModel.adverts.sort { $0.price < $1.price }
        case .priceHighToLow:
            feedViewModel.adverts.sort { $0.price > $1.price }
        case .distance:
            sortByDistance()
        }
    }

    private func sortByDistance() {
        guard let userLocation = feedViewModel.userLocation else { return }

        feedViewModel.adverts.sort {
            let loc1 = CLLocation(latitude: $0.latitude, longitude: $0.longitude)
            let loc2 = CLLocation(latitude: $1.latitude, longitude: $1.longitude)
            return userLocation.distance(from: loc1) < userLocation.distance(from: loc2)
        }
    }

    // Icon Mapping
    private func iconForJobType(_ jobType: String) -> String {
        switch jobType.lowercased() {
        case "plumbing": return "wrench.and.screwdriver.fill"
        case "electrical": return "bolt.fill"
        case "landscaping": return "leaf.fill"
        case "heating": return "flame.fill"
        case "carpentry": return "hammer.fill"
        case "painting": return "paintbrush.fill"
        case "cleaning": return "sparkles"
        case "roofing": return "house.fill"
        case "tiling": return "square.grid.3x3.fill"
        default: return "briefcase.fill"
        }
    }

    private func startChat(with receiverID: String) {
        guard let currentUserID = authViewModel.user?.email else { return }

        chatViewModel.createOrGetChat(user1: currentUserID, user2: receiverID) { chatID in
            self.chatID = chatID
            self.otherUserID = receiverID
            self.navigateToChat = true
        }
    }
}


