//
//  ChatBotViewModel.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 09/04/2025.
//

import Foundation



enum FAQCategory: String, CaseIterable {
    case feed = "Feed Page"
    case map = "Map Page"
    case profile = "Profile Page"
    case general = "General Help"
}

class ChatBotViewModel: ObservableObject {
    @Published var currentFAQs: [FAQEntry] = []

    let categorizedFAQs: [FAQCategory: [FAQEntry]] = [
        .feed: [
            FAQEntry(question: "How do I post a job?", answer: "Go to the Feed tab and tap 'Post Job'. Enter job details and submit."),
            FAQEntry(question: "How do I post a service?", answer: "Tradesmen can tap 'Upload Service' to post a service."),
            FAQEntry(question: "How do I message someone?", answer: "Tap any post and tap the message icon to start a chat."),
            FAQEntry(question: "How do I accept a job?", answer: "Open a chat and tap 'Accept Job'. When both accept, it starts."),
            FAQEntry(question: "How do I complete a job?", answer: "Tap 'Mark Job as Finished' in the chat when the job is done.")
        ],
        .map: [
            FAQEntry(question: "How does the map work?", answer: "Type a city in the search bar. Pins will show for local jobs, services, and tool shops."),
            FAQEntry(question: "Can I view jobs near me?", answer: "Yes. Use your current location or type your city to see pins nearby.")
        ],
        .profile: [
            FAQEntry(question: "How do I edit my profile?", answer: "In the Profile tab, tap 'Edit Profile' to update details."),
            FAQEntry(question: "Where can I see finished jobs?", answer: "Scroll down in your profile to view completed jobs."),
            FAQEntry(question: "How do I upload gallery images?", answer: "Use the image picker in 'Edit Profile' to select and upload job images.")
        ],
        .general: [
            FAQEntry(question: "How do I contact support?", answer: "Email w1906285@my.westminster.ac.uk or message an admin from the profile."),
            FAQEntry(question: "How do I reset my password?", answer: "Tap 'Forgot Password' on the login screen."),
            FAQEntry(question: "How do I logout?", answer: "Tap 'Logout' in your Profile tab.")
        ]
    ]

    func loadFAQs(for category: FAQCategory) {
        currentFAQs = categorizedFAQs[category] ?? []
    }
}
