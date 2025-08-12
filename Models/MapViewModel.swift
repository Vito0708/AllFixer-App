//
//  MapViewModel.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 04/03/2025.
//



import Foundation
import MapKit
import FirebaseFirestore

class MapViewModel: ObservableObject {
    @Published var jobOrAdvertAnnotations: [CustomAnnotation] = []
    @Published var toolStoreAnnotations: [CustomAnnotation] = []

    func fetchPins(userType: String) {
        let db = Firestore.firestore()
        let collection = userType == "Tradesman" ? "jobs" : "adverts"

        db.collection(collection).getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching jobs/services: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else { return }

            DispatchQueue.main.async {
                self.jobOrAdvertAnnotations = documents.compactMap { doc -> CustomAnnotation? in
                    let data = doc.data()
                    guard let title = data["title"] as? String,
                          let description = data["description"] as? String,
                          let jobType = data["jobType"] as? String,
                          let price = data["price"] as? Double,
                          let location = data["location"] as? String,
                          let latitude = data["latitude"] as? Double,
                          let longitude = data["longitude"] as? Double else {
                        return nil
                    }

                    let annotation = CustomAnnotation(
                        title: title,
                        subtitle: description,
                        jobType: jobType,
                        price: price,
                        address: location,
                        coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                        type: .jobOrAdvert
                    )

                    
                    self.fetchToolStores(near: annotation.coordinate)

                    return annotation
                }
            }
        }
    }

    
    func fetchToolStores(near coordinate: CLLocationCoordinate2D) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Tool store"
        request.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) // Search 5km radius
        )

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let response = response {
                DispatchQueue.main.async {
                    self.toolStoreAnnotations += response.mapItems.map { item in
                        CustomAnnotation(
                            title: item.name ?? "Unknown Store",
                            subtitle: "Tool Store",
                            jobType: nil,
                            price: nil,
                            address: item.placemark.title ?? "",
                            coordinate: item.placemark.coordinate,
                            type: .tradeShop
                        )
                    }
                }
            } else {
                print("❌ No tool stores found near this location.")
            }
        }
    }
}


struct CustomAnnotation: Identifiable {
    enum AnnotationType {
        case jobOrAdvert
        case tradeShop
    }

    let id = UUID()
    let title: String
    let subtitle: String
    let jobType: String?
    let price: Double?
    let address: String
    let coordinate: CLLocationCoordinate2D
    let type: AnnotationType
}


