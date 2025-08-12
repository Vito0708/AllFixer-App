//
//  ProfileView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 21/01/2025.
//

import SwiftUI
import FirebaseFirestore

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel

    @State private var editingProfile = false
    @State private var selectedJob: Job?
    @State private var selectedAdvert: Advert?
    @State private var navigateToMessages = false
    @State private var reviews: [String: Review] = [:] //  Store reviews by chatID

    var user: User? {
        authViewModel.user
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    profileHeader
                    Divider()
                    profileDetails
                    messagesButton
                    Divider()
                    savedItemsSection
                    Divider()
                    jobStatusSection
                    Divider()
                    editProfileButton
                    logoutButton
                }
            }
            
            .sheet(item: $selectedJob) { JobDetailPopup(job: $0) }
            .sheet(item: $selectedAdvert) { AdvertDetailPopup(advert: $0) }
            .background(
                NavigationLink(destination: ChatListView(), isActive: $navigateToMessages) {
                    EmptyView()
                }
            )
            .onAppear {
                if let email = authViewModel.user?.email {
                    chatViewModel.fetchChats(for: email)
                    fetchReviews(for: email)
                }
            }
        }
    }

    // Fetch Reviews from Firestore
    private func fetchReviews(for userEmail: String) {
        Firestore.firestore().collection("reviews")
            .whereField("revieweeEmail", isEqualTo: userEmail)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching reviews: \(error.localizedDescription)")
                    return
                }

                if let documents = snapshot?.documents {
                    var result: [String: Review] = [:]
                    for doc in documents {
                        if let review = try? doc.data(as: Review.self) {
                            result[review.chatID] = review
                        }
                    }

                    DispatchQueue.main.async {
                        reviews = result
                    }
                }
            }
    }

    //  Subviews

    private var profileHeader: some View {
        VStack {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
                .padding(.top, 20)

            Text(user?.displayName ?? "Unknown User")
                .font(.title)
                .fontWeight(.bold)

            Text(user?.userType ?? "Unknown")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
    }

    private var profileDetails: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.blue)
                Text(user?.email ?? "No Email Available")
            }

            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.blue)
                Text(user?.latitude != nil && user?.longitude != nil ? "Location Set" : "Location Not Available")
            }
        }
        .padding()
    }

    private var messagesButton: some View {
        Button(action: {
            navigateToMessages = true
        }) {
            HStack {
                Image(systemName: "message.fill")
                Text("Messages")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding(.horizontal)
    }

    private var savedItemsSection: some View {
        VStack(alignment: .leading) {
            Text("Saved Jobs & Services")
                .font(.headline)
                .padding(.top)

            if user?.savedJobs.isEmpty == false || user?.savedAdverts.isEmpty == false {
                List {
                    if let savedJobs = user?.savedJobs, !savedJobs.isEmpty {
                        Section(header: Text("Saved Jobs")) {
                            ForEach(savedJobs, id: \.self) { jobID in
                                Button(action: { fetchJobDetails(jobID: jobID) }) {
                                    Text("Job ID: \(jobID)").foregroundColor(.blue)
                                }
                            }
                        }
                    }

                    if let savedAdverts = user?.savedAdverts, !savedAdverts.isEmpty {
                        Section(header: Text("Saved Services")) {
                            ForEach(savedAdverts, id: \.self) { advertID in
                                Button(action: { fetchAdvertDetails(advertID: advertID) }) {
                                    Text("Advert ID: \(advertID)").foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                .frame(height: 200)
                .listStyle(PlainListStyle())
            } else {
                Text("No saved jobs or services.")
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
    }

    private var jobStatusSection: some View {
        VStack(alignment: .leading) {
            Text("Job History")
                .font(.headline)
                .padding(.top)

            let userEmail = authViewModel.user?.email ?? ""

            let jobsInProgress = chatViewModel.chats.filter {
                $0.participants.contains(userEmail) && $0.bothAccepted == true && ($0.jobFinishedBy?.count ?? 0) < 2
            }

            let completedJobs = chatViewModel.chats.filter {
                $0.participants.contains(userEmail) && ($0.jobFinishedBy?.count ?? 0) == 2
            }

            if jobsInProgress.isEmpty && completedJobs.isEmpty {
                Text("No job history found.")
                    .foregroundColor(.gray)
            }

            if !jobsInProgress.isEmpty {
                Section(header: Text("Jobs in Progress")) {
                    ForEach(jobsInProgress) { chat in
                        Text("Chat with: \(chat.participants.first { $0 != userEmail } ?? "Unknown")")
                            .foregroundColor(.orange)
                    }
                }
            }

            if !completedJobs.isEmpty {
                Section(header: Text("Completed Jobs")) {
                    ForEach(completedJobs) { chat in
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Chat with: \(chat.participants.first { $0 != userEmail } ?? "Unknown")")
                                .foregroundColor(.green)

                            if let review = reviews[chat.id ?? ""] {
                                HStack(spacing: 2) {
                                    ForEach(0..<5, id: \.self) { i in
                                        Image(systemName: i < review.rating ? "star.fill" : "star")
                                            .foregroundColor(i < review.rating ? .yellow : .gray)
                                    }
                                }
                                Text("“\(review.feedback)”")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.bottom, 8)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private var editProfileButton: some View {
        Group {
            if let user = user {
                Button(action: {
                    editingProfile = true
                }) {
                    Text("Edit Profile")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                .sheet(isPresented: $editingProfile) {
                    EditProfileView(user: user, onSave: {
                        authViewModel.fetchUserDetails(userID: user.id ?? "")
                    })
                    .environmentObject(authViewModel)
                }
            } else {
                EmptyView()
            }
        }
    }

    private var logoutButton: some View {
        Button(action: {
            authViewModel.logout()
        }) {
            Text("Log Out")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding(.horizontal)
        .padding(.bottom, 30)
    }

    //  Fetch Saved Details

    private func fetchJobDetails(jobID: String) {
        Firestore.firestore().collection("jobs").document(jobID).getDocument { document, error in
            if let document = document, document.exists,
               let job = try? document.data(as: Job.self) {
                selectedJob = job
            } else {
                print("❌ Error fetching job: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func fetchAdvertDetails(advertID: String) {
        Firestore.firestore().collection("adverts").document(advertID).getDocument { document, error in
            if let document = document, document.exists,
               let advert = try? document.data(as: Advert.self) {
                selectedAdvert = advert
            } else {
                print("❌ Error fetching advert: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}

//  Pop-up View for Saved Jobs
struct JobDetailPopup: View {
    let job: Job

    var body: some View {
        VStack {
            Text(job.title ?? "No Title")
                .font(.title2)
                .padding()

            JobRowView(job: job, isPopup: true)

            Button(action: {
                dismissPopup()
            }) {
                Text("Close")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .padding()
    }

    func dismissPopup() {
        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
    }
}

//  Pop-up View for Saved Adverts
struct AdvertDetailPopup: View {
    let advert: Advert

    var body: some View {
        VStack {
            Text(advert.title ?? "No Title")
                .font(.title2)
                .padding()

            AdvertRowView(advert: advert, isPopup: true)

            Button(action: {
                dismissPopup()
            }) {
                Text("Close")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .padding()
    }

    func dismissPopup() {
        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
    }
}


