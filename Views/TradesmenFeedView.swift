//
//  TradesmenFeedView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 21/01/2025.
//

import SwiftUI
import FirebaseFirestore
import CoreLocation
import SDWebImageSwiftUI

struct TradesmenFeedView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var feedViewModel: FeedViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel
    @State private var showPostView = false
    @State private var selectedSortOption: SortOption = .priceLowToHigh
    @State private var selectedJobType: String? = nil
    @State private var expandedPostID: String? = nil
    @State private var navigateToChat = false
    @State private var selectedChatID: String?
    @State private var selectedOtherUserID: String?
    @State private var originalJobs: [Job] = []
    @State private var searchText: String = ""

    enum SortOption {
        case priceLowToHigh, priceHighToLow, distance
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                //  Job Type Icons
                let allJobTypes = ["All", "Plumbing", "Electrical", "Landscaping", "Heating", "Carpentry", "Painting", "Cleaning", "Roofing", "Tiling"]

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(allJobTypes, id: \.self) { type in
                            Button(action: {
                                selectedJobType = (selectedJobType == type) ? nil : type
                                applyFilters()
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: iconForJobType(type)) //SF symbol based on job type
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 28, height: 28)
                                        .foregroundColor(selectedJobType == type ? .blue : .gray)

                                    Text(type)
                                        .font(.caption)
                                        .foregroundColor(selectedJobType == type ? .blue : .gray)
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

                //  Sort Options
                sortingOptions()

                //  Upload Button
                Button(action: { showPostView.toggle() }) {
                    Text("Upload Service")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#00A7E1"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                //  Job Feed
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(filteredJobs(), id: \.id) { job in
                            jobCard(for: job) //each card for a job
                        }
                    }
                    .padding()
                }
            }
            .sheet(isPresented: $showPostView) {
                PostFormView() //form to upload a service
            }
            .background(
                NavigationLink(
                    destination: ChatScreen(chatID: selectedChatID ?? "", otherUserID: selectedOtherUserID ?? ""),
                    isActive: $navigateToChat
                ) { EmptyView() }
            )
            .onAppear {
                if let userType = authViewModel.user?.userType, let userEmail = authViewModel.user?.email {
                    feedViewModel.fetchData(for: userType, currentUserEmail: userEmail)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.originalJobs = feedViewModel.jobs
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
            Text("Closest Jobs").tag(SortOption.distance)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
        .onChange(of: selectedSortOption) { _ in sortJobs() }
    }
//builds the whole card using all inforamtion needed
    private func jobCard(for job: Job) -> some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(job.title)
                        .font(.headline)
                    Text("£\(job.price, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Button(action: {
                    expandedPostID = (expandedPostID == job.id) ? nil : job.id
                }) {
                    Image(systemName: expandedPostID == job.id ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                }
            }
            .padding()

            if expandedPostID == job.id { //when the card is expanded it shows more info and the image
                VStack(alignment: .leading, spacing: 8) {
                    Text(job.description)
                        .font(.body)
                    Text("Location: \(job.location)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Job Type: \(job.jobType)")
                        .font(.subheadline)
                        .foregroundColor(.blue)

                    NavigationLink(destination: UserProfileView(userEmail: job.postedBy)) {
                        Text("Posted by: \(job.postedByName)")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .underline()
                    }
                    
                    if let avgRating = feedViewModel.averageRating(for: job.postedBy) {
                        HStack(spacing: 4) {
                            Text("★")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", avgRating))
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                    }

                    if let imageUrl = job.imageUrl {
                        WebImage(url: URL(string: imageUrl))
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        startChat(with: job.postedBy)
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

    private func startChat(with receiverID: String) {
        guard let currentUserID = authViewModel.user?.email else { return }

        chatViewModel.createOrGetChat(user1: currentUserID, user2: receiverID) { chatID in
            DispatchQueue.main.async {
                self.selectedChatID = chatID
                self.selectedOtherUserID = receiverID
                self.navigateToChat = true
            }
        }
    }

    private func sortJobs() {
        switch selectedSortOption {
        case .priceLowToHigh:
            feedViewModel.jobs.sort { $0.price < $1.price }
        case .priceHighToLow:
            feedViewModel.jobs.sort { $0.price > $1.price }
        case .distance:
            sortByDistance()
        }
    }

    private func sortByDistance() {
        guard let userLocation = feedViewModel.userLocation else { return }

        feedViewModel.jobs.sort {
            let loc1 = CLLocation(latitude: $0.latitude, longitude: $0.longitude)
            let loc2 = CLLocation(latitude: $1.latitude, longitude: $1.longitude)
            return userLocation.distance(from: loc1) < userLocation.distance(from: loc2)
        }
    }

    private func applyFilters() {
        if let selectedType = selectedJobType, selectedType != "All" {
            feedViewModel.jobs = feedViewModel.jobs.filter { $0.jobType == selectedType }
        } else {
            feedViewModel.jobs = originalJobs
        }
        sortJobs()
    }
    
    private func filteredJobs() -> [Job] {
        let typeFiltered = (selectedJobType != nil && selectedJobType != "All")
            ? originalJobs.filter { $0.jobType == selectedJobType }
            : originalJobs

        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return typeFiltered
        } else {
            return typeFiltered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

//  JOB TYPE ICON MATCHING
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


extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}


