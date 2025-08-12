//
//  EditProfileView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 30/01/2025.
//

import SwiftUI
import Firebase
import FirebaseStorage
import PhotosUI
import FirebaseAuth

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var displayName: String
    @State private var description: String
    @State private var location: String
    @State private var contactInfo: String = ""  
    @State private var jobImages: [UIImage] = []
    @State private var uploadedImageURLs: [String] = []

    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var selectedItems: [PhotosPickerItem] = []

    let onSave: () -> Void

    init(user: User, onSave: @escaping () -> Void) {
        _displayName = State(initialValue: user.displayName)
        _description = State(initialValue: user.description ?? "")
        _location = State(initialValue: user.location ?? "")
        _uploadedImageURLs = State(initialValue: user.jobImages ?? [])
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Display Name")) {
                    TextField("Company or Username", text: $displayName)
                }

                Section(header: Text("Description")) {
                    TextField("Describe your services or what you're looking for", text: $description)
                }

                Section(header: Text("Location")) {
                    TextField("City or County", text: $location)
                }

                Section(header: Text("Contact")) {
                    TextField("Enter a phone number", text: $contactInfo)
                        .textInputAutocapitalization(.never)
                }

                Section(header: Text("Gallery")) {
                    PhotosPicker(selection: $selectedItems, maxSelectionCount: 5, matching: .images) {
                        Text("Select Job Images")
                    }

                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(jobImages, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                Button(action: saveProfile) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Save Changes")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onChange(of: selectedItems) { newItems in
                for item in newItems {
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            jobImages.append(image)
                        }
                    }
                }
            }
        }
    }

    func saveProfile() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not logged in"
            return
        }

        isSaving = true

        uploadImages { newImageURLs in
            let finalImageURLs = newImageURLs.isEmpty ? uploadedImageURLs : newImageURLs

            let db = Firestore.firestore()
            db.collection("users").document(uid).updateData([
                "displayName": displayName,
                "description": description,
                "location": location,
                "jobImages": finalImageURLs
            ]) { error in
                isSaving = false
                if let error = error {
                    self.errorMessage = "Failed to update: \(error.localizedDescription)"
                } else {
                    print("✅ Firestore updated with image URLs")
                    authViewModel.fetchUserDetails(userID: uid)
                    onSave()
                    dismiss()
                }
            }
        }
    }

    func uploadImages(completion: @escaping ([String]) -> Void) {
        guard !jobImages.isEmpty else {
            completion(uploadedImageURLs)
            return
        }

        let storage = Storage.storage()
        var uploadedURLs: [String] = []
        let group = DispatchGroup()

        for image in jobImages {
            group.enter()
            let imageRef = storage.reference().child("userGallery/\(UUID().uuidString).jpg")
            if let imageData = image.jpegData(compressionQuality: 0.7) {
                imageRef.putData(imageData, metadata: nil) { _, error in
                    if error == nil {
                        imageRef.downloadURL { url, error in
                            if let url = url {
                                uploadedURLs.append(url.absoluteString)
                            }
                            group.leave()
                        }
                    } else {
                        group.leave()
                    }
                }
            } else {
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.uploadedImageURLs = uploadedURLs
            completion(uploadedURLs)
        }
    }
}
