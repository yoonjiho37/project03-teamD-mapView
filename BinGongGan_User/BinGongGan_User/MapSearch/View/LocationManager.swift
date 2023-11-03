//
//  LocationManager.swift
//  BinGongGan_User
//
//  Created by 윤지호 on 2023/09/05.
//

import Foundation
import MapKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import BinGongGanCore

final class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var mapView: MKMapView = .init()
    
    @Published var selectedCategoty: PlaceCategory = .none
    @Published var isShowingList: Bool = false
    @Published var placeList: [Place] = []
    @Published var isChaging: Bool = false
    
    private var userLocalcity: String = ""
    private var searchResult: [Place] = []
    private var seletedPlace: MKAnnotation?
    private var isSelectedAnnotation: Bool = false
    
    private var filteredPlaces: [Place] {
        return searchResult.filter { place in
            let placetest = place.address.address.components(separatedBy: " ")
            
            let isEqualLocalcity = placetest.filter { $0 == userLocalcity }.count > 0
            if selectedCategoty == .none {
                return isEqualLocalcity
            } else {
                let isEqualCategory = place.placeCategory.rawValue == selectedCategoty.rawValue
                return isEqualCategory && isEqualLocalcity
            }
        }
    }
    
    override init() {
        super.init()
        configure()
        requestAuthorizqtion()
    }
    
    private func configure() {
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func requestAuthorizqtion() {
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            moveFocusOnUserLocation()
        case .notDetermined:
            locationManager.startUpdatingLocation()
            locationManager.requestAlwaysAuthorization()
        default: break
        }
    }
}

extension LocationManager {
    
}

extension LocationManager {
    func fetchAnotations() {
        Task {
            do {
                let snapshots = try await Firestore.firestore().collection("Place").getDocuments()
                var places: [Place] = []
                snapshots.documents.forEach { snapshot in
                    do {
                        let place = try snapshot.data(as: Place.self)
                        places.append(place)
                    } catch {
                        print("error: ", error)
                    }
                }
                searchResult = places
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func searchPlace(query: String) {
        placeList = searchResult.filter { $0.placeName.trimmingCharacters(in: [" "]).contains(query) }
        DispatchQueue.main.async {
            self.isShowingList = true
        }
    }
    
    func moveFocusOnUserLocation() {
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        if !mapView.annotations.isEmpty && !placeList.isEmpty {
            let annotation = mapView.annotations.filter { $0.title == placeList[0].placeName }
            if annotation.isEmpty == false {
                mapView.deselectAnnotation(annotation[0], animated: true)
            }
        }
    }
    
    func moveFocusChange(location: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func didSelectCategory(_ category: PlaceCategory) {
        if selectedCategoty == category {
            selectedCategoty = .none
        } else {
            selectedCategoty = category
        }
        DispatchQueue.main.async {
            self.placeList = self.filteredPlaces
        }
        
        setAnnotations()
    }
    
    private func convertCLLocationToAddress(location: CLLocation) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemark, error in
            if error != nil {
                return
            }
            guard let placemark = placemark?.first else { return }
            
            if self.userLocalcity != placemark.subLocality ?? "주소없음" {
                self.userLocalcity = placemark.subLocality ?? "주소없음"
                self.setAnnotations()
            }
            return
        }
    }
    
    private func setAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        
        for place in filteredPlaces {
            let annotation = MKPointAnnotation()
            annotation.title = place.placeName
            annotation.coordinate = CLLocationCoordinate2D(latitude: place.address.latitudeDouble, longitude: place.address.longitudeDouble)
            mapView.addAnnotation(annotation)
        }
        
        DispatchQueue.main.async {
            self.placeList = self.filteredPlaces
        }
    }
}

//MARK: CLLocationManager Delegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways else { return }
        locationManager.requestLocation()
        moveFocusOnUserLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

//MARK: MapView Delegate
extension LocationManager: MKMapViewDelegate {
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        if !isChaging {
            DispatchQueue.main.async {
                self.isShowingList = false
                self.isChaging = true
            }
        }
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let location: CLLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        self.convertCLLocationToAddress(location: location)
        
        DispatchQueue.main.async {
            self.isChaging = false
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        guard let placeIndex = placeList.firstIndex(where: { $0.placeName == annotation.title }) else { return }
        let place = placeList[placeIndex]
        
        self.placeList.remove(at: placeIndex)
        self.placeList.insert(place, at: 0)
        
        seletedPlace = annotation
        moveFocusChange(location: annotation.coordinate)
        isShowingList = true
    }
}
