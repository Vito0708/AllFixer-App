//
//  ChatViewModel.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 20/03/2025.
//

import SwiftUI
import FirebaseFirestore

class ChatViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    @Published var messages: [Message] = []
    @Published var currentChat: Chat?

    private var db = Firestore.firestore()

    
    func fetchChats(for userEmail: String) {
        db.collection("chats")
            .whereField("participants", arrayContains: userEmail)
            .order(by: "lastMessageTimestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("❌ Error fetching chats: \(error.localizedDescription)")
                    return
                }

                guard let snapshot = snapshot else { return }
                DispatchQueue.main.async {
                    self.chats = snapshot.documents.compactMap {
                        try? $0.data(as: Chat.self)
                    }
                }
            }
    }

    
    func fetchMessages(for chatID: String) {
        db.collection("chats").document(chatID).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("❌ Error fetching messages: \(error.localizedDescription)")
                    return
                }

                guard let snapshot = snapshot else { return }
                DispatchQueue.main.async {
                    self.messages = snapshot.documents.compactMap {
                        try? $0.data(as: Message.self)
                    }
                }
            }

        db.collection("chats").document(chatID).addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }

            if let data = try? snapshot?.data(as: Chat.self) {
                DispatchQueue.main.async {
                    self.currentChat = data
                }
            }
        }
    }

    
    func sendMessage(chatID: String, senderID: String, text: String) {
        let message = Message(senderID: senderID, text: text, timestamp: Date())

        do {
            _ = try db.collection("chats").document(chatID).collection("messages").addDocument(from: message)
            db.collection("chats").document(chatID).updateData([
                "lastMessage": text,
                "lastMessageTimestamp": Timestamp(date: Date())
            ])
        } catch {
            print("❌ Error sending message: \(error.localizedDescription)")
        }
    }

    
    func createOrGetChat(user1: String, user2: String, completion: @escaping (String) -> Void) {
        
        let email1 = user1
        let email2 = user2

        db.collection("chats")
            .whereField("participants", arrayContains: email1)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }

                if let chat = snapshot?.documents.first(where: {
                    let participants = $0.data()["participants"] as? [String] ?? []
                    return participants.contains(email2)
                }) {
                    completion(chat.documentID)
                } else {
                    let newChat = Chat(
                        participants: [email1, email2],
                        lastMessage: "",
                        lastMessageTimestamp: Date()
                    )
                    do {
                        let ref = try self.db.collection("chats").addDocument(from: newChat)
                        completion(ref.documentID)
                    } catch {
                        print("❌ Error creating chat: \(error.localizedDescription)")
                    }
                }
            }
    }

    
    func acceptJob(chatID: String, userEmail: String) {
        let chatRef = db.collection("chats").document(chatID)

        chatRef.getDocument { snapshot, error in
            guard let doc = snapshot, var chat = try? doc.data(as: Chat.self) else { return }

            var accepted = chat.jobAcceptedBy ?? []
            if !accepted.contains(userEmail) {
                accepted.append(userEmail)
            }

            let bothAccepted = accepted.count == 2

            chatRef.updateData([
                "jobAcceptedBy": accepted,
                "bothAccepted": bothAccepted
            ]) { error in
                if let error = error {
                    print("❌ Error updating acceptance: \(error.localizedDescription)")
                } else {
                    print("✅ \(userEmail) accepted the job/service")
                }
            }
        }
    }
    
    
        func submitReview(for chatID: String, review: Review, completion: @escaping (Bool) -> Void) {
            do {
                try db.collection("chats").document(chatID).collection("reviews").document(review.reviewerEmail).setData(from: review)
                completion(true)
            } catch {
                print("❌ Error submitting review: \(error.localizedDescription)")
                completion(false)
            }
        }

        
        func hasReviewed(chatID: String, userEmail: String, completion: @escaping (Bool) -> Void) {
            let ref = db.collection("chats").document(chatID).collection("reviews").document(userEmail)
            ref.getDocument { docSnapshot, error in
                if let doc = docSnapshot, doc.exists {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }

    
    func hasUserAccepted(userEmail: String) -> Bool {
        return currentChat?.jobAcceptedBy?.contains(userEmail) ?? false
    }

    
    func hasBothAccepted() -> Bool {
        return currentChat?.bothAccepted == true
    }
    
    
        func markJobFinished(chatID: String, userEmail: String) {
            let chatRef = db.collection("chats").document(chatID)

            chatRef.getDocument { snapshot, error in
                guard let doc = snapshot, var chat = try? doc.data(as: Chat.self) else { return }

                var finished = chat.jobFinishedBy ?? []
                if !finished.contains(userEmail) {
                    finished.append(userEmail)
                }

                let jobCompleted = finished.count == 2

                chatRef.updateData([
                    "jobFinishedBy": finished,
                    "jobCompleted": jobCompleted
                ]) { error in
                    if let error = error {
                        print("❌ Error updating job finished status: \(error.localizedDescription)")
                    } else {
                        print("✅ \(userEmail) marked job as finished")
                    }
                }
            }
        }

        
        func hasUserMarkedFinished(userEmail: String) -> Bool {
            return currentChat?.jobFinishedBy?.contains(userEmail) ?? false
        }

        
        func hasBothMarkedFinished() -> Bool {
            return currentChat?.jobCompleted == true
        }
    
}




