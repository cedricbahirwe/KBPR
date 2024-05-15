//
//  IncidentsStore.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 05/05/2024.
//

import Foundation

@MainActor
class IncidentsStore: ObservableObject {
    //    @State private var incidents =  [KBIncident]()//KBIncident.incidents + KBIncident.recents
    
    @Published var allIncidents: [KBIncident] = []
    
    @Published var isLoading = false
    
    private let client: IncidentsClientProtocol
    
    init(client: IncidentsClientProtocol = IncidentsClient()) {
        self.client = client
    }
    
    func getIncidents() async {
        isLoading = true

        do {
            isLoading = true
            let results: [KBIncident] = try await client.getAll()
            isLoading = false
            allIncidents = results.sorted(by: { $0.createAt > $1.createAt })
        } catch {
            print("Error getting incidents: ", error)
            isLoading = false
        }
    }
    
    func getRecents(max: Int = 3) -> [KBIncident] {
        Array(allIncidents.prefix(max))
    }
}



class IncidentsClientMock: IncidentsClientProtocol {
    func getAll() async throws -> [KBIncident] {
        try LocalDecoder.decodeAs(from: .incidents)
    }
}

class IncidentsClient: IncidentsClientProtocol {
    private let networkClient: NetworkClient
    
    init(client: NetworkClient = .shared) {
        self.networkClient = client
    }
    func getAll() async throws -> [KBIncident] {
        try await NetworkClient.shared.get(.allIncidents)
    }
}

protocol IncidentsClientProtocol {
    func getAll() async throws -> [KBIncident]
}
