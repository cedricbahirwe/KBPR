//
//  KBPusherManager.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 27/05/2024.
//

import Foundation
import PusherSwift
import Combine


class KBPusherManager: NSObject, ObservableObject {
    static let shared = KBPusherManager()
    
    private let app_id = Constants.Pusher.app_id
    private let key = Constants.Pusher.key
    private let secret = Constants.Pusher.secret
    private let cluster = Constants.Pusher.cluster
        
    private var pusher: Pusher! = nil
    private var pusherClient: KBPusherClient! = nil
    private let decoder = JSONDecoder()
    
    
    let emergencyDelegate = PassthroughSubject<(alert: EmergencyAlert,name: KBPusherEventName), Never>()
//    var emergencyDelegate: EmergencyAlertDelegate?
    
    func connect() {
        guard pusher != nil else {
            configure()
            return
        }
        pusher.connect()
    }
    
    func disconnect() {
        guard pusher != nil else { return }
        pusher.disconnect()
    }
    
    func configure() {
        // Only use your secret here for testing or if you're sure that there's
        // no security risk
        let options = PusherClientOptions(host: .cluster(cluster))
        let pusherClientOptions = PusherClientOptions(authMethod: .inline(secret: secret))
        pusher = Pusher(key: key, options: options)
      
        pusher.delegate = self
        
        pusher.connect()
        
        
        // Initialize Client HTTP
        pusherClient = KBPusherClient(
            cluster,
            secret: secret,
            key: key, appId: Int(app_id)!
        )
        
        
        // bind to all events globally
        _ = pusher.bind(eventCallback: { (event: PusherEvent) in
            var message = "Received event: '\(event.eventName)'"
            
            if let channel = event.channelName {
                message += " on channel '\(channel)'"
            }
            if let userId = event.userId {
                message += " from user '\(userId)'"
            }
            if let data = event.data {
                message += " with data '\(data)'"
            }
            
            print(message)
        })
        
        subscribeToEmergencies()
        
    }
    
}

// MARK: - PusherDelegate methods

extension KBPusherManager: PusherDelegate {
    
    func changedConnectionState(from old: ConnectionState, to new: ConnectionState) {
        // print the old and new connection states
        print("old: \(old.stringValue()) -> new: \(new.stringValue())")
    }
    
    func subscribedToChannel(name: String) {
        print("Subscribed to \(name)")
    }
    
    func debugLog(message: String) {
        print("DEBUG LOG++", message)
    }
    
    func receivedError(error: PusherError) {
        if let code = error.code {
            print("Received error: (\(code)) \(error.message)")
        } else {
            print("Received error: \(error.message)")
        }
    }
}

// MARK: - Emergencies Channel Subscriptions

extension KBPusherManager {
    // Trigger SOS emergency
    func publishSOSEvent() async {
        guard let sender = LocalStorage.getSessionUser() else { return }
        let data = SOSEmergency(
            title: "Park Ranger in distress",
            description: "Need urgeny assistance",
            sender: sender.toShort()
        )
        let event = KBPusherEvent(
            name: .sosStart,
            channel: .emergencies,
            data: data
        )
        pusherClient.triggerEvent(event: event)
    }
    
    func stopSOSEvent() {
        guard let sender = LocalStorage.getSessionUser() else { return }
        let data = SOSEmergency(sender: sender.toShort())
        let event = KBPusherEvent(
            name: .sosEnd,
            channel: .emergencies,
            data: data
        )
        pusherClient.triggerEvent(event: event)
    }
    
    func subscribeToEmergencies() {
        let myChannel = pusher.subscribe(.emergencies)
        
        // Emergency started, event received
        myChannel.bind(eventName: .sosStart, eventCallback: { [weak self ] (event: PusherEvent) in
            guard let self, let sessionUser = LocalStorage.getSessionUser() else { return }
            
            do {
                let alert = try decodeEmergencyEvent(event).alert
                guard sessionUser.id != alert.sender.id else { return }
                emergencyDelegate.send((alert, .sosStart))
            } catch {
                print("Final error", error.localizedDescription)
            }
        })
        
        // Emergency stopped, event received
        myChannel.bind(eventName: .sosEnd, eventCallback: { [weak self ] (event: PusherEvent) in
            guard let self, let sessionUser = LocalStorage.getSessionUser() else { return }

            do {
                let alert = try decodeEmergencyEvent(event).alert
                guard sessionUser.id != alert.sender.id else { return }
                emergencyDelegate.send((alert, .sosEnd))
            } catch {
                print("Final error", error.localizedDescription)
            }
           
        })
        
        func decodeEmergencyEvent(_ event: PusherEvent) throws -> EmergencyAlertWrapper {
            guard let json: String = event.data,
                  let jsonData: Data = json.data(using: .utf8)
            else {
                print("Could not convert JSON string to data", event.data ?? "-")
                throw KBPusherError.unableToConvertToJSON
            }
            
            do {
                return try self.decoder.decode(EmergencyAlertWrapper.self, from: jsonData)
            } catch {
                print("Could not decode message", error.localizedDescription)
                throw error
            }
        }
    }
}


extension Pusher {
    func subscribe(_ channelName: KBPusherChannelName) -> PusherChannel {
        self.subscribe(channelName: channelName.rawValue)
    }
}

extension PusherChannel {
    @discardableResult func bind(eventName: KBPusherEventName, eventCallback: @escaping (PusherEvent) -> Void) -> String {
        self.bind(eventName: eventName.rawValue, eventCallback: eventCallback)
    }
}


enum KBPusherError: Error {
    case unableToConvertToJSON
}
enum KBPusherChannelName: String {
    case emergencies = "emergencies"
}

enum KBPusherEventName: String {
    case sosStart = "sos-start"
    case sosEnd = "sos-end"
    case sosResponse = "sos-response"
}
