//
//  LoginView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 18/03/2025.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var showForgotPassword = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack(alignment: .top) {
            
            VStack(spacing: 0) {
                Color(hex: "#00A7E1")
                    .frame(height: UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44)
                Spacer()
            }
            .edgesIgnoringSafeArea(.top)

            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                
                ZStack {
                    Color(hex: "#00A7E1")
                        .ignoresSafeArea()

                    VStack(spacing: 10) {
                        Image("handyman")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .shadow(radius: 4)

                        Text("Welcome Back!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("Login to continue")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.top, 60)
                }
                .frame(height: UIScreen.main.bounds.height * 0.38)
                .clipShape(RoundedCorner(radius: 40, corners: [.bottomLeft, .bottomRight]))

                // Login form section
                VStack(spacing: 20) {
                    CustomTextField(icon: "envelope", placeholder: "Email", text: $email)
                    CustomSecureField(icon: "lock", placeholder: "Password", text: $password)

                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    
                    HStack {
                        Spacer()
                        Button("Forgot Password?") {
                            showForgotPassword = true
                        }
                        .font(.footnote)
                        .foregroundColor(Color(hex: "#00A7E1"))
                        Spacer()
                    }

                    Button(action: {
                        authViewModel.login(email: email, password: password) { error in
                            self.errorMessage = error?.localizedDescription
                        }
                    }) {
                        Text("Login")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#00A7E1"))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                    }

                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.gray)
                        Button("Sign Up") {
                            showSignUp = true
                        }
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#00A7E1"))
                    }
                    .padding(.bottom, 16)
                }
                .padding()
                .background(Color.white)
                .clipShape(RoundedCorner(radius: 30, corners: [.topLeft, .topRight]))
            }
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
    }
}


struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .padding(.leading, 10)

            TextField(placeholder, text: $text)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
        }
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}


struct CustomSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .padding(.leading, 10)

            SecureField(placeholder, text: $text)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
        }
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}


extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}


struct RoundedCorner: Shape {
    var radius: CGFloat = 25
    var corners: UIRectCorner = [.allCorners]

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    LoginView().environmentObject(AuthViewModel())
}
