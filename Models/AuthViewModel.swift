//
//  AuthViewModel.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 19/02/2025.
//

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoggedIn: Bool = false

    init() {
        checkUserSession()
    }

    func checkUserSession() {
        if let currentUser = Auth.auth().currentUser {
            fetchUserDetails(userID: currentUser.uid)
            DispatchQueue.main.async {
                self.isLoggedIn = true
            }
        } else {
            DispatchQueue.main.async {
                self.isLoggedIn = false
            }
        }
    }

    func signUp(email: String, password: String, userType: String, name: String, latitude: Double, longitude: Double, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error)
            } else if let firebaseUser = result?.user {
                let newUser = User(
                    id: firebaseUser.uid,
                    name: name,
                    email: email,
                    userType: userType,
                    latitude: latitude,
                    longitude: longitude,
                    savedJobs: [],
                    savedAdverts: [],
                    displayName: name,
                    description: "",
                    location: nil,
                    jobImages: nil,  
                    isVerified: userType == "Tradesman" ? false : true
                    
                )

                let db = Firestore.firestore()
                db.collection("users").document(firebaseUser.uid).setData([
                    "name": name,
                    "email": email,
                    "userType": userType,
                    "latitude": latitude,
                    "longitude": longitude,
                    "savedJobs": [],
                    "savedAdverts": [],
                    "isVerified": userType == "Tradesman" ? false : true,
                    "displayName": name
                ]) { error in
                    if let error = error {
                        print("❌ Error saving user to Firestore: \(error.localizedDescription)")
                    }
                }

                DispatchQueue.main.async {
                    self.user = newUser
                    self.isLoggedIn = true
                }
                completion(nil)
            }
        }
    }

    func signUpWithUploads(email: String, password: String, userType: String, name: String, latitude: Double, longitude: Double, certificateUrl: String, idUrl: String, selfieUrl: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error)
            } else if let firebaseUser = result?.user {
                let db = Firestore.firestore()
                let userData: [String: Any] = [
                    "name": name,
                    "email": email,
                    "userType": userType,
                    "latitude": latitude,
                    "longitude": longitude,
                    "savedJobs": [],
                    "savedAdverts": [],
                    "certificateUrl": certificateUrl,
                    "idUrl": idUrl,
                    "selfieUrl": selfieUrl,
                    "isVerified": false,
                    "displayName": name
                ]

                db.collection("users").document(firebaseUser.uid).setData(userData) { error in
                    if let error = error {
                        print("❌ Firestore error: \(error.localizedDescription)")
                    }
                }

                DispatchQueue.main.async {
                    self.user = User(
                        id: firebaseUser.uid,
                        name: name,
                        email: email,
                        userType: userType,
                        latitude: latitude,
                        longitude: longitude,
                        savedJobs: [],
                        savedAdverts: [],
                        displayName: name,
                        description: "",
                        location: nil,
                        jobImages: nil,
                        isVerified: false
                        
                    )
                    self.isLoggedIn = true
                }
                completion(nil)
            }
        }
    }

    func login(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error)
            } else if let firebaseUser = result?.user {
                self.fetchUserDetails(userID: firebaseUser.uid)
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                }
                completion(nil)
            }
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.user = nil
                self.isLoggedIn = false
            }
        } catch {
            print("❌ Error logging out: \(error.localizedDescription)")
        }
    }

    func fetchUserDetails(userID: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userID).getDocument { (document, error) in
            if let document = document, let data = document.data() {
                let fetchedUser = User(
                    id: userID,
                    name: data["name"] as? String ?? "Unknown",
                    email: data["email"] as? String ?? "",
                    userType: data["userType"] as? String ?? "UNKNOWN",
                    latitude: data["latitude"] as? Double ?? 0.0,
                    longitude: data["longitude"] as? Double ?? 0.0,
                    savedJobs: data["savedJobs"] as? [String] ?? [],
                    savedAdverts: data["savedAdverts"] as? [String] ?? [],
                    displayName: data["displayName"] as? String ?? "Unknown",
                    description: data["description"] as? String ?? "",
                    location: data["location"] as? String,
                    jobImages: data["jobImages"] as? [String],          
                    isVerified: data["isVerified"] as? Bool ?? true
                    
                )

                DispatchQueue.main.async {
                    self.user = fetchedUser
                    self.isLoggedIn = true
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoggedIn = false
                }
                print("❌ Error fetching user details: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func saveJob(jobID: String) {
        guard let userID = user?.id else { return }
        if user?.savedJobs.contains(jobID) == false {
            user?.savedJobs.append(jobID)
            Firestore.firestore().collection("users").document(userID).updateData([
                "savedJobs": FieldValue.arrayUnion([jobID])
            ])
        }
    }

    func removeSavedJob(jobID: String) {
        guard let userID = user?.id else { return }
        user?.savedJobs.removeAll { $0 == jobID }
        Firestore.firestore().collection("users").document(userID).updateData([
            "savedJobs": FieldValue.arrayRemove([jobID])
        ])
    }

    func saveAdvert(advertID: String) {
        guard let userID = user?.id else { return }
        if user?.savedAdverts.contains(advertID) == false {
            user?.savedAdverts.append(advertID)
            Firestore.firestore().collection("users").document(userID).updateData([
                "savedAdverts": FieldValue.arrayUnion([advertID])
            ])
        }
    }

    func removeSavedAdvert(advertID: String) {
        guard let userID = user?.id else { return }
        user?.savedAdverts.removeAll { $0 == advertID }
        Firestore.firestore().collection("users").document(userID).updateData([
            "savedAdverts": FieldValue.arrayRemove([advertID])
        ])
    }

    func isJobSaved(jobID: String) -> Bool {
        return user?.savedJobs.contains(jobID) ?? false
    }

    func isAdvertSaved(advertID: String) -> Bool {
        return user?.savedAdverts.contains(advertID) ?? false
    }

    func resetPassword(email: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
}


