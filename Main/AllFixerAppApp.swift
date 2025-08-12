//
//  AllFixerAppApp.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 21/01/2025.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct AllFixerAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var chatViewModel = ChatViewModel()

    var body: some Scene {
        WindowGroup {
            if authViewModel.isLoggedIn,
               let userType = authViewModel.user?.userType,
               let userEmail = authViewModel.user?.email {
                
                let feedViewModel = FeedViewModel(userType: userType, currentUserEmail: userEmail)

                //  Branch here based on user type
                if userType == "Admin" {
                    AdminTabBarView()
                        .environmentObject(authViewModel)
                        .environmentObject(feedViewModel)
                        .environmentObject(chatViewModel)
                } else {
                    TabBarView(userType: userType)
                        .environmentObject(authViewModel)
                        .environmentObject(feedViewModel)
                        .environmentObject(chatViewModel)
                }

            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}


