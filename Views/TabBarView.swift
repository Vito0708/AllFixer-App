//
//  TabBarView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 27/02/2025.
//

import SwiftUI

struct TabBarView: View {
    var userType: String
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showChatBot = false
    
    var body: some View {
        NavigationView {
            if userType == "Admin" {
                AdminTabBarView() // Admin-specific tab layout
                    .environmentObject(authViewModel)
            } else {
                ZStack {
                    // Main TabView content for non-admin users
                    TabView {
                        // Feed Page
                        if userType == "Tradesman" {
                            TradesmenFeedView()
                                .tabItem {
                                    Image(systemName: "list.bullet")
                                    Text("Feed")
                                }
                        } else {
                            HomeownerFeedView()
                                .tabItem {
                                    Image(systemName: "list.bullet")
                                    Text("Feed")
                                }
                        }
                        
                        // Map Page
                        MapView(userType: userType)
                            .tabItem {
                                Image(systemName: "map")
                                Text("Map")
                            }
                        
                        // Profile Page
                        ProfileView()
                            .tabItem {
                                Image(systemName: "person.crop.circle")
                                Text("Profile")
                            }
                    }
                    
                    // Floating ChatBot Button overlay
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                showChatBot.toggle()
                            }) {
                                Image(systemName: "message.circle.fill")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.blue)
                                    .shadow(radius: 4)
                            }
                            
                            .padding(.bottom, 80)
                            .padding(.trailing, 16)
                        }
                    }
                }
                .sheet(isPresented: $showChatBot) {
                    ChatBotView()
                }
                .navigationBarHidden(true)
            }
        }
    }
}

#Preview {
    TabBarView(userType: "Tradesman").environmentObject(AuthViewModel())
}
