//
//  PostFormView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 26/02/2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import CoreLocation

struct PostFormView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var title = ""
    @State private var description = ""
    @State private var selectedType = "Plumbing"
    @State private var price: String = ""
    @State private var location = ""
    @State private var isSubmitting = false
    @State private var showVerificationAlert = false

    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var imageUrl: String? = nil

    let jobTypes = ["Plumbing", "Electrical", "Landscaping", "Carpentry", "Painting", "Gas", "Builder", "Heating", "Tiling", "Roofing"]

    var body: some View {
        VStack {
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                }
                .padding()

                Spacer()

                Text("Create a New Post")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()
                Spacer().frame(width: 40)
            }

            TextField("Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Description", text: $description)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Picker("Select Type", selection: $selectedType) {
                ForEach(jobTypes, id: \.self) { type in
                    Text(type).tag(type)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()

            TextField("Price", text: $price)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Location (Postcode or City)", text: $location)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                showImagePicker = true
            }) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                    Text(selectedImage == nil ? "Upload Image" : "Image Selected")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "#00A7E1"))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()

            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .cornerRadius(10)
                    .padding()
            }

            Button(action: submitPost) {
                Text(isSubmitting ? "Posting..." : "Post")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#00A7E1"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            .disabled(isSubmitting)
        }
        .padding()
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .alert(isPresented: $showVerificationAlert) {
            Alert(
                title: Text("Account Not Verified"),
                message: Text("Your account has not been verified by an admin yet. Please wait for approval before posting."),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    func submitPost() {
        guard let user = authViewModel.user else { return }

        if user.userType == "Tradesman", user.isVerified == false {
            showVerificationAlert = true
            return
        }

        isSubmitting = true
        let geocoder = CLGeocoder()

        geocoder.geocodeAddressString(location) { placemarks, error in
            let coordinates = placemarks?.first?.location?.coordinate
            let latitude = coordinates?.latitude ?? 0.0
            let longitude = coordinates?.longitude ?? 0.0

            if let image = selectedImage {
                uploadImage(image) { imageUrl in
                    self.imageUrl = imageUrl
                    self.savePostToDatabase(latitude: latitude, longitude: longitude, imageUrl: imageUrl)
                }
            } else {
                self.savePostToDatabase(latitude: latitude, longitude: longitude, imageUrl: nil)
            }
        }
    }

    private func uploadImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }

        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("post_images/\(UUID().uuidString).jpg")

        imageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("❌ Image upload error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            imageRef.downloadURL { url, error in
                if let error = error {
                    print("❌ Failed to get download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                completion(url?.absoluteString)
            }
        }
    }

    private func savePostToDatabase(latitude: Double, longitude: Double, imageUrl: String?) {
        let db = Firestore.firestore()
        let collection = authViewModel.user?.userType == "Homeowner" ? "jobs" : "adverts"
        let newPostID = UUID().uuidString

        var postData: [String: Any] = [
            "id": newPostID,
            "title": title,
            "description": description,
            "price": Double(price) ?? 0,
            "location": location,
            "postedBy": authViewModel.user?.email ?? "Unknown",
            "postedByName": authViewModel.user?.displayName ?? "Anonymous",
            "createdAt": Timestamp(),
            "rating": 5.0,
            "latitude": latitude,
            "longitude": longitude,
            "jobType": selectedType
        ]

        if let imageUrl = imageUrl {
            postData["imageUrl"] = imageUrl
        }

        db.collection(collection).document(newPostID).setData(postData) { error in
            if let error = error {
                print("❌ Firestore error: \(error.localizedDescription)")
            } else {
                print("✅ Successfully posted with image in \(collection) collection")
            }
            isSubmitting = false
            presentationMode.wrappedValue.dismiss()
        }
    }
}


