//
//  SignUpView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 19/02/2025.
//

import SwiftUI
import FirebaseStorage

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var name = "" // Company name (tradesmen)
    @State private var username = "" // Username (homeowner)
    @State private var email = ""
    @State private var password = ""
    @State private var userType = "Tradesman"
    @State private var latitude: Double = 51.509865
    @State private var longitude: Double = -0.118092
    @State private var errorMessage: String?

    // For uploading tradesman verification documents
    @State private var certificateImage: UIImage?
    @State private var idImage: UIImage?
    @State private var selfieImage: UIImage?

    @State private var showingCertificatePicker = false
    @State private var showingIDPicker = false
    @State private var showingSelfiePicker = false
    @State private var isUploading = false

    let primaryColor = Color(hex: "#00A7E1")
    let accentColor = Color(hex: "#E94F37")

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 15) {
                    Spacer()

                    Text("Sign Up")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(primaryColor)

                    if userType == "Tradesman" {
                        CustomTextField(icon: "person.fill", placeholder: "Company Name", text: $name)
                    } else {
                        CustomTextField(icon: "person.fill", placeholder: "Username", text: $username)
                    }

                    CustomTextField(icon: "envelope.fill", placeholder: "Email", text: $email)

                    CustomSecureField(icon: "lock.fill", placeholder: "Password", text: $password)

                    Picker("User Type", selection: $userType) {
                        Text("Tradesman").tag("Tradesman")
                        Text("Homeowner").tag("Homeowner")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    if userType == "Tradesman" {
                        VStack(spacing: 10) {
                            uploadButton(title: "Upload Certificate", image: $certificateImage, showPicker: $showingCertificatePicker)
                            uploadButton(title: "Upload ID", image: $idImage, showPicker: $showingIDPicker)
                            uploadButton(title: "Upload Selfie", image: $selfieImage, showPicker: $showingSelfiePicker)
                        }
                    }

                    Button(action: signUp) {
                        Text(isUploading ? "Creating..." : "Create Account")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    }
                    .padding(.horizontal)
                    .disabled(isUploading)

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(accentColor)
                            .font(.footnote)
                            .padding(.top, 5)
                    }

                    Spacer()
                }
                .padding()
            }

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
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingCertificatePicker) {
            ImagePicker(selectedImage: $certificateImage)
        }
        .sheet(isPresented: $showingIDPicker) {
            ImagePicker(selectedImage: $idImage)
        }
        .sheet(isPresented: $showingSelfiePicker) {
            ImagePicker(selectedImage: $selfieImage)
        }
    }

    private func uploadButton(title: String, image: Binding<UIImage?>, showPicker: Binding<Bool>) -> some View {
        Button(action: {
            showPicker.wrappedValue = true
        }) {
            HStack {
                Image(systemName: image.wrappedValue == nil ? "photo.on.rectangle" : "checkmark.seal.fill")
                Text(image.wrappedValue == nil ? title : "\(title) ✅")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(image.wrappedValue == nil ? Color.gray.opacity(0.2) : Color.green.opacity(0.8))
            .foregroundColor(.primary)
            .cornerRadius(8)
        }
    }

    private func signUp() {
        errorMessage = nil

        let displayName = userType == "Tradesman" ? name : username

        guard !displayName.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        if userType == "Tradesman" {
            guard certificateImage != nil, idImage != nil, selfieImage != nil else {
                errorMessage = "All three images must be uploaded."
                return
            }

            isUploading = true
            uploadAllImages { certificateURL, idURL, selfieURL in
                guard let cert = certificateURL, let id = idURL, let selfie = selfieURL else {
                    errorMessage = "Image upload failed. Try again."
                    isUploading = false
                    return
                }

                authViewModel.signUpWithUploads(
                    email: email,
                    password: password,
                    userType: userType,
                    name: displayName,
                    latitude: latitude,
                    longitude: longitude,
                    certificateUrl: cert,
                    idUrl: id,
                    selfieUrl: selfie
                ) { error in
                    isUploading = false
                    if let error = error {
                        errorMessage = error.localizedDescription
                    }
                }
            }

        } else {
            authViewModel.signUp(
                email: email,
                password: password,
                userType: userType,
                name: displayName,
                latitude: latitude,
                longitude: longitude
            ) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func uploadAllImages(completion: @escaping (String?, String?, String?) -> Void) {
        let group = DispatchGroup()
        var certificateURL: String?
        var idURL: String?
        var selfieURL: String?

        func upload(_ image: UIImage?, name: String, result: @escaping (String?) -> Void) {
            guard let image = image, let imageData = image.jpegData(compressionQuality: 0.8) else {
                result(nil)
                return
            }

            let ref = Storage.storage().reference().child("verifications/\(UUID().uuidString)_\(name).jpg")
            ref.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("❌ Upload error (\(name)): \(error.localizedDescription)")
                    result(nil)
                    return
                }

                ref.downloadURL { url, error in
                    result(url?.absoluteString)
                }
            }
        }

        group.enter()
        upload(certificateImage, name: "certificate") {
            certificateURL = $0
            group.leave()
        }

        group.enter()
        upload(idImage, name: "id") {
            idURL = $0
            group.leave()
        }

        group.enter()
        upload(selfieImage, name: "selfie") {
            selfieURL = $0
            group.leave()
        }

        group.notify(queue: .main) {
            completion(certificateURL, idURL, selfieURL)
        }
    }
}

#Preview {
    SignUpView().environmentObject(AuthViewModel())
}
