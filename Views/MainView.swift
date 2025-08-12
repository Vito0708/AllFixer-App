//
//  MainView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 21/01/2025.
//

import SwiftUI

struct MainView: View {
    let userType: String
    
    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Feed")
                }
            
            MapView(userType: userType)  
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
    }
}

#Preview {
    MainView(userType: "Tradesman")
}









