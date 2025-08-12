//
//  ContentView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 21/01/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        
        if authViewModel.isLoggedIn {
            if let userType = authViewModel.user?.userType {
                TabBarView(userType: userType)
            } else {
                ProgressView()
            }
        } else {
            LoginView()
        }
    }
}

#Preview {
    ContentView().environmentObject(AuthViewModel())
}






