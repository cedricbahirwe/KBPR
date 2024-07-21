//
//  IncidentsStore.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 05/05/2024.
//

import Foundation

@MainActor class IncidentsStore: ObservableObject {    
    @Published var allIncidents: [KBIncident] = []
    
    @Published var isLoading = false
    
    private let client: IncidentsClientProtocol
    
    init(client: IncidentsClientProtocol = IncidentsClient()) {
        self.client = client
    }
    
    func getIncidents() async {

        do {
            if allIncidents.isEmpty  {
                isLoading = true
            }
            let results: [KBIncident] = try await client.getAll()
            isLoading = false
            allIncidents = results.sorted(by: { $0.createAt > $1.createAt })
        } catch {
            print("Error getting incidents: ", error)
            isLoading = false
        }
    }
    
    func uploadMedias(_ medias: [Media]) async throws -> [KBIncident.Attachment] {
        do {
            isLoading = true
            let asyncUploads: [KBIncident.Attachment] = try await withThrowingTaskGroup(of: KBIncident.Attachment.self) { group in
                for media in medias {
                    group.addTask {
                        switch media {
                        case .image(let image):
                            let imageURL = try await KBFBStorage.shared.uploadImage(image)
                            return .init(type: .Photo, url: imageURL)
                        case .movie(let movie):
                            let videoURL = try await KBFBStorage.shared.uploadMovie(movie.url)
                            return .init(type: .Video, url: videoURL)
                        }
                    }
                }
                
                var results = [KBIncident.Attachment]()
                for try await result in group {
                    results.append(result)
                }
                return results
            }
            print("Media upload finished: ", asyncUploads)
            return asyncUploads
        } catch {
            isLoading = false
            throw error
        }
    }
    
    func submitIncidentReport(_ report: IncidentModel) async {
        isLoading = true

        do {
            isLoading = true
            let newIncident: KBIncident = try await client.reportIncident(report)
            self.prependIncident(newIncident)
            isLoading = false
        } catch {
            print("Error submitting: ", error)
            isLoading = false
        }
    }
    
    func updateIncidentCategory(_ incident: KBIncident, newCategory: KBIncident.Category) async -> KBIncident? {
        do {
            let update = ["category": newCategory.rawValue]
            let updateIncident: KBIncident = try await NetworkClient.shared.put(.updateIncidentStatus(incidentID: incident.id), content: update)
            if let index = allIncidents.firstIndex(where: { $0.id == updateIncident.id }) {
                self.allIncidents[index] = updateIncident
            }
            return updateIncident
        } catch {
            print("Error update status: ", error.localizedDescription)
            return nil
        }
    }
    
    func updateIncidentStatus(_ incident: KBIncident, newStatus: KBIncident.Status) async -> KBIncident? {
        do {
            let statusUpdate = ["status": newStatus.rawValue]
            let updateIncident: KBIncident = try await NetworkClient.shared.put(.updateIncidentStatus(incidentID: incident.id), content: statusUpdate)
            if let index = allIncidents.firstIndex(where: { $0.id == updateIncident.id }) {
                self.allIncidents[index] = updateIncident
            }
            return updateIncident
        } catch {
            print("Error update status: ", error.localizedDescription)
            return nil
        }
    }
    
    func prependIncident(_ incident: KBIncident) {
        self.allIncidents.insert(incident, at: 0)
    }
    
    func getRecents(max: Int = 3) -> [KBIncident] {
        Array(allIncidents.prefix(max))
    }
}



class IncidentsClientMock: IncidentsClientProtocol {
    func getAll() async throws -> [KBIncident] {
        try LocalDecoder.decodeAs(from: .incidents)
    }
    
    func reportIncident(_ incident: IncidentModel) async throws -> KBIncident {
        KBIncident.recents[0]
    }
}

class IncidentsClient: IncidentsClientProtocol {
    private let networkClient: NetworkClient
    
    init(client: NetworkClient = .shared) {
        self.networkClient = client
    }
    func getAll() async throws -> [KBIncident] {
        try await networkClient.get(.allIncidents)
    }
    
    func reportIncident(_ incident: IncidentModel) async throws -> KBIncident {
        try await networkClient.post(.newIncident, content: incident)
    }
}

protocol IncidentsClientProtocol {
    func getAll() async throws -> [KBIncident]
    
    func reportIncident(_ incident: IncidentModel) async throws -> KBIncident
}
