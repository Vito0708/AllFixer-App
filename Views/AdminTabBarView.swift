//
//  AdminTabBarView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 23/03/2025.
//

import SwiftUI

struct AdminTabBarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        TabView {
            // All Posts
            AdminPanelView()
                .tabItem {
                    Image(systemName: "doc.text.magnifyingglass")
                    Text("All Posts")
                }

            // Verification Requests
            AdminVerifyRequestsView()
                .tabItem {
                    Image(systemName: "checkmark.seal")
                    Text("Requests")
                }

            // Profile + Logout
            AdminProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
        }
    }
}

#Preview {
    AdminTabBarView().environmentObject(AuthViewModel())
}
