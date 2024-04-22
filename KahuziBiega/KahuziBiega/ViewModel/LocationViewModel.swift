//
//  LocationViewModel.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 22/04/2024.
//

import Foundation
import SwiftUI
import MapKit

final class LocationViewModel: ObservableObject {
    let mapSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    
    @Published var locations: [Location]
    
    @Published var mapLocation: Location {
        didSet {
            updateMapRegion(location: mapLocation)
        }
    }
    
    @Published var cameraPosition: MapCameraPosition = .automatic
    
    
    @Published var showLocationList: Bool = false
    
    @Published var showSheet: Location? = nil
    
    init() {
        let locations = LocationsDataService.locations
        self.locations = locations
        self.mapLocation = locations.first!
        
        updateMapRegion(location: locations.first!)
    }
    
    private func updateMapRegion(location: Location) {
        withAnimation(.easeInOut) {
            updateCameraPosition(MKCoordinateRegion(center: location.coordinates, span: mapSpan))
        }
    }
    
    func updateCameraPosition(_ region: MKCoordinateRegion) {
        cameraPosition = MapCameraPosition.region(region)
    }
    
    func toggleLocationsList() {
        withAnimation(.easeInOut) {
            showLocationList.toggle()
        }
    }
    
    func showNextLocation(location: Location) {
        withAnimation(.easeInOut) {
            mapLocation = location
            showLocationList = false
        }
    }
    
    func nextButtonClicked() {
        guard let currentIndex = locations.firstIndex(where: {$0 == mapLocation}) else {return}
        
        let nextIndex = currentIndex + 1
        
        guard locations.indices.contains(nextIndex) else {
            guard let firstLocation = locations.first else {return}
            showNextLocation(location: firstLocation)
            return
        }
        
        let nextLocation = locations[nextIndex]
        showNextLocation(location: nextLocation)
    }
}

struct Location: Identifiable, Equatable {
    let name: String
    let cityName: String
    let coordinates: CLLocationCoordinate2D
    let description : String
    let imageNames: [String]
    let link: String
    
    var id: String {
        name + cityName
    }
    
    //Equatable
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
}

enum LocationsDataService {
    
    static let userLocation = CLLocationCoordinate2D(latitude: -1.952770744198159, longitude: 30.10567634656355)
    static let kigaliHeights = CLLocationCoordinate2D(latitude: -1.954287, longitude: 30.091983)
    
    static let locations: [Location] = [
        Location(
            name: "Heydar Mosque",
            cityName: "Kigali",
            coordinates: CLLocationCoordinate2D(
                latitude: -1.952770744198159,
                longitude: 30.10567634656355
            ),
            description: "Heydar Mosque is an Azerbaijani mosque named after Heydar Aliyev, in the Binəqədi raion of Baku. The mosque covers a total area of 12,000 m2 and the internal area of the building covers a total area of 4,200 square meters. This mosqueis the largest construction cult-religious architecture not only in Azerbaijan, but also in the entire South Caucasus",
            imageNames: [
                "heydar-mosque-1",
                "heydar-mosque-2",
            ],
            link: "https://en.wikipedia.org/wiki/Heydar_Mosque"
        ),
        Location(
            name: "Maiden Tower",
            cityName: "Kigali",
            coordinates: CLLocationCoordinate2D(
                latitude: -1.9480327691570364,
                longitude: 30.09990216750799
            ),
            description: "The Maiden Tower is a 12th-century monument in the Old City, Baku, Azerbaijan. Along with the Shirvanshahs' Palace, dated to the 15th century, it forms a group of historic monuments listed in 2001 under the UNESCO World Heritage List of Historical Monuments as cultural property.",
            imageNames: [
                "maiden-tower-1",
                "maiden-tower-2",
                "maiden-tower-3",
            ],
            link: "https://en.wikipedia.org/wiki/Maiden_Tower_(Baku)"
        )
    ]
}
