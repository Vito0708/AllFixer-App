//
//  FeedView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 26/02/2025.
//



import SwiftUI

struct FeedView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var feedViewModel = FeedViewModel(userType: "", currentUserEmail: nil)
    
    var body: some View {
        Group {
            if let userType = authViewModel.user?.userType, let userEmail = authViewModel.user?.email {
                if userType == "Tradesman" {
                    TradesmenFeedView()
                        .environmentObject(feedViewModel) // Inject FeedViewModel
                } else {
                    HomeownerFeedView()
                        .environmentObject(feedViewModel) //  Inject FeedViewModel
                }
            } else {
                ProgressView() // loading state while fetching user data
            }
        }
        .onAppear {
            if let userType = authViewModel.user?.userType,
               let userEmail = authViewModel.user?.email {
                print("🔄 Fetching Data for \(userType)")
                feedViewModel.fetchData(for: userType, currentUserEmail: userEmail)
            }
        }
    }
}

#Preview {
    FeedView().environmentObject(AuthViewModel())
}


