//
//  AgreementViewModel.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 25/03/2025.
//

import Foundation
import FirebaseFirestore


class AgreementViewModel: ObservableObject {
    @Published var agreementStatus: AgreementStatus?

    func fetchAgreement(chatID: String, currentUserID: String, otherUserID: String) {
        let db = Firestore.firestore()
        db.collection("agreements")
            .whereField("chatID", isEqualTo: chatID)
            .getDocuments { snapshot, error in
                if let document = snapshot?.documents.first {
                    do {
                        self.agreementStatus = try document.data(as: AgreementStatus.self)
                    } catch {
                        print("❌ Error decoding agreement: \(error.localizedDescription)")
                    }
                } else {
                    // If not found create a new one
                    self.createAgreement(chatID: chatID, senderID: currentUserID, receiverID: otherUserID)
                }
            }
    }

    func createAgreement(chatID: String, senderID: String, receiverID: String) {
        let db = Firestore.firestore()
        let agreement = AgreementStatus(
            id: UUID().uuidString,
            chatID: chatID,
            senderID: senderID,
            receiverID: receiverID,
            senderAccepted: false,
            receiverAccepted: false,
            timestamp: Date()
        )

        do {
            try db.collection("agreements").document(agreement.id).setData(from: agreement)
            self.agreementStatus = agreement
        } catch {
            print("❌ Error creating agreement: \(error.localizedDescription)")
        }
    }

    func acceptAgreement(userID: String) {
        guard var agreement = agreementStatus else { return }

        if userID == agreement.senderID {
            agreement.senderAccepted = true
        } else if userID == agreement.receiverID {
            agreement.receiverAccepted = true
        }

        let db = Firestore.firestore()
        do {
            try db.collection("agreements").document(agreement.id).setData(from: agreement)
            self.agreementStatus = agreement
        } catch {
            print("❌ Error updating agreement: \(error.localizedDescription)")
        }
    }

    var isFullyAccepted: Bool {
        return agreementStatus?.senderAccepted == true && agreementStatus?.receiverAccepted == true
    }
}
