//
//  IncidentsStore.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 05/05/2024.
//

import Foundation

@MainActor
final class IncidentsStore: ObservableObject {
    //    @State private var incidents =  [KBIncident]()//KBIncident.incidents + KBIncident.recents
    
    @Published var allIncidents: [KBIncident] = []
    
    @Published var isLoading = false
    
    let client = NetworkClient.shared
    
    init() { }
    
    func getIncidents() async {
        do {
            isLoading = true
            let results: [KBIncident] = try await client.get(.getIncidents)
            print("Some incidents", results.count)
            allIncidents = results
            
        } catch {
            print("Error getting incidents: ", error)
            isLoading = false
        }
    }
}
