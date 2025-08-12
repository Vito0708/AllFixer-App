//
//  ChatBotView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 09/04/2025.
//

import SwiftUI

struct ChatBotView: View {
    @Environment(\.dismiss) var dismiss
    @State private var messages: [String] = ["🤖 Hello! What can I help you with today?"]
    @ObservedObject var viewModel = ChatBotViewModel()
    @State private var selectedCategory: FAQCategory? = nil
    @State private var expandedQuestionID: UUID? = nil

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(messages, id: \.self) { msg in //shows all user and bot messages 
                            HStack {
                                if msg.starts(with: "You:") {
                                    Spacer()
                                    Text(msg)
                                        .padding()
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(8)
                                } else {
                                    Text(msg)
                                        .padding()
                                        .background(Color.green.opacity(0.2))
                                        .cornerRadius(8)
                                    Spacer()
                                }
                            }
                        }

                        if let category = selectedCategory { //shows FAQs when category selected
                            Text("🤖 Here are some common questions about the \(category.rawValue):")
                                .padding(.top)

                            ForEach(viewModel.currentFAQs) { faq in
                                VStack(alignment: .leading, spacing: 6) {
                                    Button(action: {
                                        withAnimation {
                                            if expandedQuestionID == faq.id {
                                                expandedQuestionID = nil
                                            } else {
                                                expandedQuestionID = faq.id
                                            }
                                        }
                                    }) {
                                        Text("• \(faq.question)") //FAQs shown as buttons
                                            .foregroundColor(.black)
                                            .padding()
                                            .background(Color.green.opacity(0.2))
                                            .cornerRadius(8)
                                    }

                                    if expandedQuestionID == faq.id { //show answer when question is clicked
                                        Text(faq.answer)
                                            .font(.subheadline)
                                            .padding(.horizontal)
                                            .transition(.opacity)
                                    }
                                }
                                .animation(.easeInOut, value: expandedQuestionID)
                            }
                        }
                    }
                    .padding()
                }

                if selectedCategory == nil { //if no category selected show options
                    VStack(spacing: 10) {
                        Text("Choose a category:")
                            .font(.headline)
                            .padding(.top)

                        ForEach(FAQCategory.allCases, id: \.self) { category in //list each category as button
                            Button(action: {
                                selectedCategory = category
                                viewModel.loadFAQs(for: category)
                            }) {
                                Text(category.rawValue)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Assistant")
            .navigationBarItems(leading: Button("Close") {
                dismiss()
            }, trailing: Button("Reset") { //reset to home page of chat bot
                selectedCategory = nil
                expandedQuestionID = nil
                messages = ["🤖 Hello! What can I help you with today?"]
            })
        }
    }
}


