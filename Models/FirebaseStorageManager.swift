//
//  FirebaseStorageManager.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 19/03/2025.
//

import FirebaseStorage
import UIKit

struct FirebaseStorageManager {
    static func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageConversionError", code: -1, userInfo: nil)))
            return
        }

        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("post_images/\(UUID().uuidString).jpg")

        imageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            imageRef.downloadURL { url, error in
                if let url = url {
                    completion(.success(url.absoluteString))
                } else {
                    completion(.failure(error ?? NSError(domain: "DownloadURLError", code: -1, userInfo: nil)))
                }
            }
        }
    }
}
