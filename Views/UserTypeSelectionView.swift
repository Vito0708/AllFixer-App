//
//  UserTypeSelectionView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 21/01/2025.
//

import SwiftUI

struct UserTypeSelectionView: View {
    @Binding var userType: String?
    @Binding var navigateToLogin: Bool

    var body: some View {
        VStack(spacing: 40) {
            Text("Select Your Role")
                .font(.largeTitle)
                .fontWeight(.bold)

            Button(action: {
                userType = "Tradesmen"
                navigateToLogin = true
            }) {
                Text("I am a Tradesman")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)

            Button(action: {
                userType = "Homeowner"
                navigateToLogin = true
            }) {
                Text("I am a Homeowner")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
        }
        .padding()
    }
}





