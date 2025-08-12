//
//  MapView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 21/01/2025.
//
//


import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @ObservedObject var mapViewModel = MapViewModel()
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var feedViewModel: FeedViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.509865, longitude: -0.118092), // Centres the map to default London
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var searchQuery: String = "" //stores searches
    @State private var selectedAnnotation: CustomAnnotation? = nil //stores clicked pins

    let userType: String //determines weather to show jobs or adverts

    var jobAnnotations: [CustomAnnotation] {
        return mapViewModel.jobOrAdvertAnnotations //fetches jobs and adverts pins
    }

    var storeAnnotations: [CustomAnnotation] {
        return mapViewModel.toolStoreAnnotations // fetches tool store pins
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    // Search Bar
                    HStack {
                        TextField("Enter a city (e.g., Manchester)", text: $searchQuery, onCommit: {
                            searchCity()
                        })
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)

                        Button(action: searchCity) {
                            Image(systemName: "magnifyingglass")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        .padding(.trailing)
                    }
                    .padding(.top, 10)

                    // Map View
                    ZStack {
                        Map(coordinateRegion: Binding(get: { region }, set: { region = $0 }), //binding map region
                            annotationItems: jobAnnotations + storeAnnotations) { annotation in //shows both post types
                            MapAnnotation(coordinate: annotation.coordinate) {
                                VStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(annotation.type == .jobOrAdvert ? .blue : .orange) //  Blue for Jobs, Orange for Tool Stores
                                        .font(.title)
                                        .onTapGesture {
                                            selectedAnnotation = annotation //show popup for selected pin
                                        }
                                    Text(annotation.title)
                                        .font(.caption)
                                        .padding(2)
                                        .background(Color.white)
                                        .cornerRadius(5)
                                }
                            }
                        }
                        .edgesIgnoringSafeArea(.all) //map fills whole screen

                        //  Popup for Selected Annotation
                        if let annotation = selectedAnnotation {
                            annotationPopup(annotation)
                        }
                    }
                }
                .onAppear {
                    mapViewModel.fetchPins(userType: userType) //  Load pins based on user type
                }

                //  Zoom Controls
                zoomControls
            }
        }
    }

    //  Search for a City and Update Map
    func searchCity() {
        let geocoder = CLGeocoder() //initialize geocoderr to convert text to coordinates
        geocoder.geocodeAddressString(searchQuery) { placemarks, error in
            if let placemark = placemarks?.first, let location = placemark.location {
                region = MKCoordinateRegion( //centre map on a new location
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                )
            }
        }
    }

    //  Open Apple Maps for Directions
    func openInAppleMaps(destination: CLLocationCoordinate2D) {
        let url = URL(string: "http://maps.apple.com/?daddr=\(destination.latitude),\(destination.longitude)&dirflg=d")!
        UIApplication.shared.open(url)
    }

    //  Zoom In/Out Controls
    var zoomControls: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: 10) {
                    Button(action: zoomIn) {
                        Image(systemName: "plus.magnifyingglass")
                            .frame(width: 50, height: 50)
                            .background(Color.white)
                            .cornerRadius(25)
                            .shadow(radius: 3)
                    }
                    Button(action: zoomOut) {
                        Image(systemName: "minus.magnifyingglass")
                            .frame(width: 50, height: 50)
                            .background(Color.white)
                            .cornerRadius(25)
                            .shadow(radius: 3)
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 100)
            }
        }
    }

    //  Popup for Selected Annotation
    func annotationPopup(_ annotation: CustomAnnotation) -> some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(annotation.title)
                        .font(.headline)
                    Spacer()
                    Button(action: { selectedAnnotation = nil }) { //dissmis popup
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                Text(annotation.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if annotation.type == .jobOrAdvert {
                    Text("Job Type: \(annotation.jobType ?? "Unknown")")
                    Text("Price: £\(annotation.price ?? 0, specifier: "%.2f")")
                } else {
                    Text("Store Type: Tool Store")
                }

                Text("Location: \(annotation.address)")

                
                if annotation.type == .jobOrAdvert {
                    Button(action: {
                        
                        DispatchQueue.main.async {
                            feedViewModel.navigateToPost(postID: annotation.id.uuidString) //navigate to post in feed
                        }
                        
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            presentationMode.wrappedValue.dismiss() //close map
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                            Text("Take me to this \(userType == "Tradesman" ? "Job" : "Service")")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }

                
                Button(action: {
                    openInAppleMaps(destination: annotation.coordinate)
                }) {
                    HStack {
                        Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                        Text("Get Directions")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 10)
            .padding()
        }
        .transition(.move(edge: .bottom))
        .animation(.spring())
    }

    //  Zoom In/Out Functions
    func zoomIn() {
        let newLatitudeDelta = max(region.span.latitudeDelta / 2, 0.002)
        let newLongitudeDelta = max(region.span.longitudeDelta / 2, 0.002)
        region.span = MKCoordinateSpan(latitudeDelta: newLatitudeDelta, longitudeDelta: newLongitudeDelta)
    }

    func zoomOut() {
        let newLatitudeDelta = min(region.span.latitudeDelta * 2, 10.0)
        let newLongitudeDelta = min(region.span.longitudeDelta * 2, 10.0)
        region.span = MKCoordinateSpan(latitudeDelta: newLatitudeDelta, longitudeDelta: newLongitudeDelta)
    }
}


