//
//  MapScreen.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 22/04/2024.
//

import SwiftUI
import MapKit

struct MapScreen: View {
    @StateObject private var locationVM = LocationViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    var locationRadius: CGFloat { 600.0 }
    
    
    var body: some View {
        ZStack {
            Map(position: $locationVM.cameraPosition, interactionModes: .all)  {
                ForEach(locationVM.locations) { location in
                    Annotation(location.name, coordinate: location.coordinates) {
                        LocationMapAnnotationView(image: .init(.img3))
                            .scaleEffect(locationVM.mapLocation == location ? 1 : 0.7)
                            .shadow(radius: 10)
                            .onTapGesture {
                                locationVM.showNextLocation(location: location)
                            }
                    }
                }
                .annotationTitles(.hidden )
                
                
                MapCircle(center: LocationsDataService.userLocation, radius: locationRadius)
                    .foregroundStyle(.accent.opacity(0.3))
                    .stroke(
                        LinearGradient(colors: [.white, .gray], startPoint: .top, endPoint: .bottom),
                        lineWidth: 4
                    )
                
//                            UserAnnotation()
            }
//            .onMapCameraChange(frequency: .continuous) { mapCameraUpdateContext in
//                locationVM.updateCameraPosition(mapCameraUpdateContext.region)
//            }
            .mapStyle(.imagery(elevation: .realistic))
//            .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll))
            
            
            searchFieldView
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private var searchFieldView: some View {
        VStack {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .bold()
                        .padding(10)
                        .clipShape(.circle)
                        .background(.background.shadow(.drop(radius: 3, x: 0, y: 3)), in: .circle)
                }
                
                TextField("", text: $searchText)
                    .autocorrectionDisabled()
                
                Button(action: {
                }) {
                    Image(.avatarImg)
                        .resizable()
                        .scaledToFit()
                }
                
            }
            .padding(8)
            .frame(height: 48)
            .background(
                .background.shadow(.drop(color: .black, radius: 10, x: 0, y: 10)),
                in: .capsule
            )
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    MapScreen()
}
