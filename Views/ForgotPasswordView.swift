//
//  ForgotPasswordView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 18/03/2025.
//
import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?

    let primaryColor = Color(hex: "#00A7E1")
    let accentColor = Color(hex: "#E94F37")

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack {
                
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(primaryColor)
                    }
                    .padding(.top, 50)
                    .padding(.leading, 20)

                    Spacer()
                }

                Spacer()

                // Mail image
                Image("mail")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130, height: 130)
                    .padding(.bottom, 10)

                // Title
                Text("Reset Password")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(primaryColor)

                Text("Enter your email to reset password")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 20)

                // Email input
                CustomTextField(icon: "envelope.fill", placeholder: "Email", text: $email)
                    .padding(.top, 10)
                    .padding(.horizontal)

                // Feedback messages
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(accentColor)
                        .font(.footnote)
                        .padding(.top, 5)
                }

                if let successMessage = successMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .font(.footnote)
                        .padding(.top, 5)
                }

                // Submit button
                Button(action: {
                    authViewModel.resetPassword(email: email) { error in
                        if let error = error {
                            self.errorMessage = error.localizedDescription
                            self.successMessage = nil
                        } else {
                            self.successMessage = "Password reset email sent!"
                            self.errorMessage = nil
                        }
                    }
                }) {
                    Text("Send Reset Link")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(primaryColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                }
                .padding(.horizontal)
                .padding(.top, 10)

                Spacer()
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    ForgotPasswordView().environmentObject(AuthViewModel())
}
