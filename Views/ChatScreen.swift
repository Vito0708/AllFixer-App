//
//  ChatScreen.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 20/03/2025.
//


import SwiftUI
import FirebaseFirestore

struct ChatScreen: View {
    @State private var messageText = ""
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel

    let chatID: String
    let otherUserID: String

    @State private var otherUserDisplayName: String?
    @State private var showReviewPopup = false

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(chatViewModel.messages) { message in
                        HStack {
                            if message.senderID == authViewModel.user?.email {
                                Spacer()
                                Text(message.text)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            } else {
                                Text(message.text)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                Spacer()
                            }
                        }
                    }

                    if chatViewModel.hasBothMarkedFinished() {
                        Text("🏁 Job completed by both users.")
                            .foregroundColor(.purple)
                            .font(.subheadline)
                            .padding(.top, 10)
                    } else if chatViewModel.hasBothAccepted() {
                        Text("✅ Job in progress.")
                            .foregroundColor(.green)
                            .font(.subheadline)
                            .padding(.top, 10)
                    }
                }
                .padding()
            }

            VStack(spacing: 10) {
                // Accept Job Button
                if let userEmail = authViewModel.user?.email,
                   !chatViewModel.hasUserAccepted(userEmail: userEmail),
                   !chatViewModel.hasBothAccepted() {
                    Button(action: {
                        chatViewModel.acceptJob(chatID: chatID, userEmail: userEmail)
                    }) {
                        Text("Accept Job/Service")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }

                // Finish Job Button
                if let userEmail = authViewModel.user?.email,
                   chatViewModel.hasBothAccepted(),
                   !chatViewModel.hasUserMarkedFinished(userEmail: userEmail),
                   !chatViewModel.hasBothMarkedFinished() {
                    Button(action: {
                        chatViewModel.markJobFinished(chatID: chatID, userEmail: userEmail)
                    }) {
                        Text("Mark Job as Finished")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }

                // Message Input
                HStack {
                    TextField("Type a message...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: {
                        if let senderID = authViewModel.user?.email {
                            chatViewModel.sendMessage(chatID: chatID, senderID: senderID, text: messageText)
                            messageText = ""
                        }
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(otherUserDisplayName ?? "Chat")
        .onAppear {
            chatViewModel.fetchMessages(for: chatID)
            fetchOtherUserDisplayName()

            // Show review popup if job is completed and not reviewed
            if let userEmail = authViewModel.user?.email {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if chatViewModel.hasBothMarkedFinished() {
                        chatViewModel.hasReviewed(chatID: chatID, userEmail: userEmail) { hasReviewed in
                            if !hasReviewed {
                                showReviewPopup = true
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showReviewPopup) {
            ReviewPopupContainer(
                chatID: chatID,
                otherUserID: otherUserID,
                dismiss: { showReviewPopup = false }
            )
            .environmentObject(chatViewModel)
            .environmentObject(authViewModel)
        }
    }

    private func fetchOtherUserDisplayName() {
        Firestore.firestore()
            .collection("users")
            .whereField("email", isEqualTo: otherUserID)
            .getDocuments { snapshot, error in
                if let document = snapshot?.documents.first,
                   let name = document.data()["displayName"] as? String {
                    DispatchQueue.main.async {
                        self.otherUserDisplayName = name
                    }
                }
            }
    }
}


private struct ReviewPopupContainer: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel

    let chatID: String
    let otherUserID: String
    let dismiss: () -> Void

    var body: some View {
        if let reviewerEmail = authViewModel.user?.email {
            ReviewPopupView(
                chatID: chatID,
                reviewerEmail: reviewerEmail,
                revieweeEmail: otherUserID,
                jobID: chatID,
                onSubmit: dismiss
            )
            .environmentObject(chatViewModel)
        }
    }
}
