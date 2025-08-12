//
//  AdminProfileView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 23/03/2025.
//

import SwiftUI

struct AdminProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            if let user = authViewModel.user {
                VStack(spacing: 10) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)

                    Text(user.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(user.email)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Button(action: {
                authViewModel.logout()
            }) {
                Text("Log Out")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .navigationTitle("Admin Profile")
    }
}
