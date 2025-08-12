//
//  ChatListView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 20/03/2025.
//

import SwiftUI
import FirebaseFirestore

struct ChatListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel
    @State private var displayNames: [String: String] = [:]

    var body: some View {
        NavigationView {
            VStack {
                if chatViewModel.chats.isEmpty {
                    Text("No messages yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(chatViewModel.chats) { chat in
                        if let otherUserID = chat.participants.first(where: { $0 != authViewModel.user?.email }) {
                            NavigationLink(destination: ChatScreen(chatID: chat.id ?? "", otherUserID: otherUserID)) {
                                VStack(alignment: .leading) {
                                    Text("Chat with \(displayNames[otherUserID] ?? otherUserID)")
                                        .font(.headline)
                                    Text(chat.lastMessage)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            .onAppear {
                                fetchDisplayName(for: otherUserID)
                            }
                        } else {
                            Text("Error: Unable to load chat")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Messages")
            .onAppear {
                if let userEmail = authViewModel.user?.email {
                    print("🔍 Fetching chats for user: \(userEmail)")
                    chatViewModel.fetchChats(for: userEmail)
                } else {
                    print("❌ Error: No authenticated user found.")
                }
            }
        }
    }

    // Fetch display name of the other user
    private func fetchDisplayName(for email: String) {
        guard displayNames[email] == nil else { return }

        Firestore.firestore()
            .collection("users")
            .whereField("email", isEqualTo: email)
            .getDocuments { snapshot, error in
                if let document = snapshot?.documents.first,
                   let displayName = document.data()["displayName"] as? String {
                    DispatchQueue.main.async {
                        displayNames[email] = displayName
                    }
                }
            }
    }
}



