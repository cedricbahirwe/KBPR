//
//  KBIncident.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 28/04/2024.
//

import Foundation

struct KBIncident: Identifiable, Decodable {
    var id: UUID
    var report: KBIncident.Report
    var priority: KBIncident.Priority
    var status: KBIncident.Status
    var category: KBIncident.Category
    var resolution: KBIncident.Resolution?
    var createAt: Date
    var updatedAt: Date
    var resolvedAt: Date?
    
    
    init(
        id: UUID = UUID(),
        report: KBIncident.Report,
        priority: KBIncident.Priority,
        category: KBIncident.Category,
        status: KBIncident.Status,
        resolution: KBIncident.Resolution? = nil,
        createAt: Date = .now,
        updatedAt: Date = .now,
        resolvedAt: Date? = nil
    ) {
        self.id = id
        self.report = report
        self.priority = priority
        self.status = status
        self.category = category
        self.resolution = resolution
        self.createAt = createAt
        self.updatedAt = updatedAt
        self.resolvedAt = resolvedAt
    }
    
    struct Report: Identifiable, Decodable {
        var id: UUID // should I have this?
        var title: String
        var description: String
        var comments: String?
        var area: IncidentArea?
        var attachements: [AttachmentType]?
        var reporter: KBUser
        
        init(id: UUID = UUID(), title: String, description: String, comments: String? = nil, area: IncidentArea, attachements: [AttachmentType] = [], reporter: KBUser) {
            self.id = id
            self.title = title
            self.description = description
            self.comments = comments
            self.area = area
            self.attachements = attachements
            self.reporter = reporter
        }
    }
    
    enum Status: String, CaseIterable, Codable {
        case pending = "Pending",
             inReview = "InReview",
             inProgress = "InProgress",
             resolved = "Resolved"
        
        var formatted: String {
            switch self {
            case .pending: "Pending"
            case .inReview: "In Review"
            case .inProgress: "In Progress"
            case .resolved: "Resolved"
            }
        }
    }
    
    enum Priority: String, Codable, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case highest = "Highest"
    }
    
    enum Category: String, Codable, CaseIterable {
        case poaching, parkDamage, hunting, medical, safety, environmental, other
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValueString = try container.decode(String.self)
            
            if let resolvedValue = Category(rawValue: rawValueString.lowercased()) {
                self = resolvedValue
            } else {
                self = .other
            }
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue.capitalized)
        }
        
        var formatted: String {
            switch self {
            case .poaching, .environmental, .safety, .other: rawValue.capitalized
            case .parkDamage: "Damage to Park"
            case .hunting: "Illegal Hunting"
            case .medical: "Medical Emergency"
            }
        }
    }
    
    struct IncidentArea: Decodable {
        var name: String
        var latitude: Double
        var longitude: Double
        
        static let example = IncidentArea(name: "Visitor Center Area", latitude: 0.0032123, longitude: -1.2141241)
        static let example1 = IncidentArea(name: "Mountain Gorilla North Wing", latitude: 0.012123, longitude: -1.141241)
    }
    
    
    enum AttachmentType: Decodable {
        case photo(URL)
        case video(URL)
    }
    
    struct Resolution: Codable {
        var comments: String?
        var resolver: KBUser
    }
    
}

extension KBIncident {
    
    static let incidents = [
        KBIncident(report: .report1, priority: .medium, category: .other, status: .inReview),
        KBIncident(report: .report2, priority: .medium, category: .other, status: .inReview)
    ]
    
    static let recents = [
        KBIncident(report: .report3, priority: .high, category: .hunting, status: .inReview),
        KBIncident(report: .report4, priority: .high, category: .hunting, status: .resolved),
    ]
    
}

extension KBIncident.Report {
    
    static let report1 = KBIncident.Report(
        title: "Illegal hunting activity near the Visitor Center Area",
        description: "On the morning patrol, encountered a group of visitors near the Eastern Trail Area who had an unexpected ..",
        area: .example,
        reporter: .example
    )
    
    static let report2 = KBIncident.Report(
        title: "Another Incident XYZ",
        description: "Something happened in the night and should check this and that before or access....",
        area: .example1,
        reporter: .example
    )
    
    static let report3 = KBIncident.Report(
        title: "Encounter with juvenile mountain gorilla",
        description: "On the morning patrol, encountered a group of visitors near the Eastern Trail Area who had an unexpected close encounter with a juvenile mountain gorilla.",
        area: .example1,
        reporter: .example
    )
    
    static let report4 = KBIncident.Report(
        title: "Illegal hunting activity near the Visitor Center Area.",
        description: "Upon investigation, discovered evidence of poaching, including animal traps and remains of a hunted antelope. The perpetrators had already fled the scene before ...",
        area: .example1,
        reporter: .example
    )
}

import SwiftUI

extension KBIncident.Status {
    var color: Color {
        switch self {
        case .pending: .pending
        case .inReview: .inReview
        case .inProgress: .inProgress
        case .resolved: .resolved
        }
    }
}

extension KBIncident.Priority {
    func getColor() -> Color {
        switch self {
        case .low:
                .green
        case .medium:
                .teal
        case .high:
                .orange
        case .highest:
                .darkRed
        }
    }
}
