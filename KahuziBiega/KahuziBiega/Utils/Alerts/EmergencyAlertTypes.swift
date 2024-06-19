//
//  EmergencyAlertTypes.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 19/06/2024.
//

import Foundation
import CoreLocation

struct KBGPS: Codable {
    let latitude: Double
    let longitude: Double
}

protocol EmergencyAlert: Codable {
    var id: UUID { get }
    var title: String? { get }
    var description: String? { get }
    var sender: KBUserShort { get }
    var type: EmergencyAlertType { get }
}

enum EmergencyAlertType: String, Codable {
    case sos
    
    var metatype: any EmergencyAlert.Type {
        switch self {
        case .sos:
            SOSEmergency.self
        }
    }
}

struct SOSEmergency: EmergencyAlert {
    var id: UUID = UUID()
    var title: String?
    var description: String?
    var sender: KBUserShort
    var type: EmergencyAlertType
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.sender = try container.decode(KBUserShort.self, forKey: .sender)
        self.type = try container.decode(EmergencyAlertType.self, forKey: .type)
    }
    
    init(id: UUID = UUID(), title: String? = nil, description: String? = nil, sender: KBUserShort, type: EmergencyAlertType = .sos) {
        self.id = id
        self.title = title
        self.description = description
        self.sender = sender
        self.type = type
    }
}

struct EmergencyAlertWrapper: Codable {
    var alert: any EmergencyAlert
    
    private enum CodingKeys: String, CodingKey {
        case type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(EmergencyAlertType.self, forKey: .type)
        self.alert = try type.metatype.init(from: decoder)
    }
    
    func encode(to encoder: any Encoder) throws {
        try alert.encode(to: encoder)
    }
}

struct KBPusherEvent<T: Codable> {
    let name: KBPusherEventName
    let channel: KBPusherChannelName
    let data: T
}
