//
//  HeatMapView.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 20/07/2024.
//

import UIKit
import MapKit
import SwiftUI

final class MapViewModel: ObservableObject {
    @Published var boost: Float = 0.4
    @Published var locations: [CLLocation] = []
    @Published var weights: [NSNumber] = []
    @Published var heatmapImage: UIImage?
    
    init() {
        loadData()
    }
    
    private func loadData() {
        guard let dataFile = Bundle.main.path(forResource: "quake_100", ofType: "plist"),
              let quakeData = NSArray(contentsOfFile: dataFile) as? [[String: Any]]
        else { return }
        
        locations = []
        weights = []
        
        for reading in quakeData {
            if let latitude = reading["latitude"] as? CLLocationDegrees,
               let longitude = reading["longitude"] as? CLLocationDegrees,
               let magnitude = reading["magnitude"] as? Double {
                
                let location = CLLocation(latitude: latitude, longitude: longitude)
                locations.append(location)
                
                weights.append(NSNumber(value: Int(magnitude * 10)))
            }
        }
    }
    
    func makeHeatMap(for mapView: MKMapView) {
        let heatmap = LFHeatMap.heatMapForMapView(mapView, boost: boost, locations: locations, weights: weights)
        heatmapImage = heatmap
    }
    
}


struct MapView: UIViewRepresentable {
    @ObservedObject var viewModel: MapViewModel
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(parent: MapView) {
            self.parent = parent
        }
        
        func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
            parent.viewModel.makeHeatMap(for: mapView)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.mapType = .hybrid
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        let coordinate = CLLocationCoordinate2D(latitude: -2.315211, longitude: 28.757437)
        let span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        uiView.setRegion(region, animated: true)
    }
}
