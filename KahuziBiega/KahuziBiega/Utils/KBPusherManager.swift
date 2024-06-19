//
//  KBPusherManager.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 27/05/2024.
//

import Foundation
import PusherSwift

import CryptoSwift
import CryptoKit

class KBPusherManager: NSObject, PusherDelegate {
    private let app_id = "962207"
    private let key = "fd4d4731402adac340ad"
    private let secret = "fd97f4ac7fddf699759d"
    private let cluster = "ap2"
    
    private let audioManager = SOSAlertView.AudioManager()
    
    private var pusher: Pusher! = nil
    private let decoder = JSONDecoder()
    
    static let shared = KBPusherManager()
    
    var emergencyDelegate: EmergencyAlertDelegate?
    
    func connect() {
        pusher.connect()
    }
    
    func disconnect() {
        pusher.disconnect()
    }
    
    override init() {
        super.init()
    }
    
    func configure() {
        
        // Only use your secret here for testing or if you're sure that there's
        // no security risk
        let options = PusherClientOptions(host: .cluster(cluster))
        let pusherClientOptions = PusherClientOptions(authMethod: .inline(secret: secret))
        pusher = Pusher(key: key, options: options)
        
        
        
//        let pusher = PusherEvent()
        // Use this if you want to try out your auth endpoint
        //        let optionsWithEndpoint = PusherClientOptions(
        //            authMethod: AuthMethod.authRequestBuilder(authRequestBuilder: AuthRequestBuilder())
        //        )
        //        pusher = Pusher(key: "YOUR_APP_KEY", options: optionsWithEndpoint)
        
        // Use this if you want to try out your auth endpoint (deprecated method)
        
        pusher.delegate = self
        
        pusher.connect()
        
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
        
        // subscribe to a channel
        let myChannel = pusher.subscribe("my-channel")
        
        // bind a callback to event "my-event" on that channel
        _ = myChannel.bind(eventName: "my-event", eventCallback: { (event: PusherEvent) in
            print("Calling back")
            // convert the data string to type data for decoding
            guard let json: String = event.data,
                  let jsonData: Data = json.data(using: .utf8)
            else {
                print("Could not convert JSON string to data")
                return
            }
            
            // decode the event data as json into a DebugConsoleMessage
            let decodedMessage = try? self.decoder.decode(DebugConsoleMessage.self, from: jsonData)
            guard let message = decodedMessage else {
                print("Could not decode message")
                return
            }
            
            print("\(message.name) says \(message.message)")
        })
        
        subscribeToEmergencies()
        
        
    }
    
    //    func publishEvent(channel: String, event: String, data: [String: Any]) async throws {
    //
    //
    //        let url = URL(string: "https://api-\(cluster).pusher.com/apps/\(app_id)/events")!
    //
    //        // Prepare the payload
    //        let eventData: [String: Any] = [
    //            "name": event,
    //            "channels": [channel],
    //            "data": data.jsonString() // Convert the data dictionary to JSON string
    //        ]
    //
    //        let bodyData = try! JSONSerialization.data(withJSONObject: eventData, options: [])
    //        let bodyString = String(data: bodyData, encoding: .utf8)!
    //
    //        // Generate the authentication signature
    //        let authSignature = generateAuthSignature(bodyString: bodyString)
    //
    //        print("Signature ", authSignature, Date().timeIntervalSince1970)
    //        // Prepare the headers
    //        let headers = [
    //            "Content-Type": "application/json",
    //            "Authorization": "Bearer \(authSignature)"
    //        ]
    //
    //        // Prepare the request
    //        var request = URLRequest(url: url)
    //        request.httpMethod = "POST"
    //        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    //        request.setValue(key, forHTTPHeaderField: "auth_key")
    //        request.setValue("\(Date().timeIntervalSince1970)", forHTTPHeaderField: "auth_timestamp")
    //        request.setValue("1.0", forHTTPHeaderField: "auth_version")
    //
    //        request.setValue("Bearer \(authSignature)", forHTTPHeaderField: "Authorization")
    //        request.httpBody = bodyData
    //
    //        // Make the POST request
    //
    //        let (data, response) = try await URLSession.shared.data(for: request)
    //
    //        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
    //            print("Response is",  response)
    //            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Invalid response"])
    //            throw error
    //        }
    //    }
    
    
    
    
    func publishEvent() async throws {
        guard let sender = LocalStorage.getSessionUser() else { return }
        let emergency = SOSEmergency(id: UUID(),
                                     title: "This is urgent",
                                     description: "Some description",
                                     sender: sender.toShort())
        
        let pusherEvent = MyPusherEvent(name: "sos",
                                        channels: ["emergencies"],
                                        data: emergency)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let bodyData = try encoder.encode(pusherEvent)
        let bodyString = String(data: bodyData, encoding: .utf8)!
        
//        let body = """
//        {"name":"sos","channels":["emergencies"],"data":"{\\"some\\":\\"data\\"}"}
//        """
        let authTimestamp = Date().timeIntervalSince1970// "1353088179"
        let authVersion = "1.0"
        
        // Compute MD5 hash of the body
        let bodyMD5 = Insecure.MD5.hash(data: bodyData).map { String(format: "%02hhx", $0) }.joined()
//        let bodyMD5 = Insecure.MD5.hash(data: body.data(using: .utf8)!).map { String(format: "%02hhx", $0) }.joined()
        
        print("Body md5: \(bodyMD5)\n", bodyString)
        
        // Create the string to sign
        let stringToSign = """
        POST
        /apps/\(app_id)/events
        auth_key=\(key)&auth_timestamp=\(authTimestamp)&auth_version=\(authVersion)&body_md5=\(bodyMD5)
        """
        
        print("String to sign: \(stringToSign)\n")
        
        return;
        
        // Generate the HMAC SHA-256 authentication signature
        let authSignature = try HMAC(key: secret, variant: .sha2(.sha256)).authenticate(stringToSign.bytes).toHexString()
        
        print("Auth signature: \(authSignature)\n")
        
        // Create the URL
        let urlString = "https://api-\(cluster).pusher.com/apps/\(app_id)/events?auth_key=\(key)&auth_timestamp=\(authTimestamp)&auth_version=\(authVersion)&body_md5=\(bodyMD5)&auth_signature=\(authSignature)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        
        // Send the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Response status code: \(httpResponse.statusCode)")
        }
        
        if let responseBody = String(data: data, encoding: .utf8) {
            print("Response body: \(responseBody)")
        }
    }
    
    private func generateAuthSignature(bodyString: String) -> String {
        let key = secret
        let data = bodyString
        
        let hmac = try! HMAC(key: key.bytes, variant: .sha2(.sha256)).authenticate(data.bytes)
        return hmac.toHexString()
    }
    
    
    // PusherDelegate methods
    
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

protocol EmergencyAlertDelegate {
    func didReceiveAlert(alert: EmergencyAlert)
}

// Subscribe to emergices channel
extension KBPusherManager {
    func publishSOSEvent() async {
        guard let sender = LocalStorage.getSessionUser() else { return }
        
        print("Triggering notification")
        // triggers a client event on that channel
        //        let chan  = pusher.connection.channels.find(name: "emergencies")
        
        
        //        print("Found", chan?.name)
                let data = SOSEmergency(id: UUID(),
                                        title: "This is urgent",
                                        description: "Some description",
                                        sender: sender.toShort())
        
        //        chan?.trigger(eventName: "sos", data: ["test": "some value"])
        
        let options = PusherClientOptions(host: .cluster(cluster))
        KBPusherClient.shared.triggerEvent(
            cluster,
            secret: secret,
            key: key, appId: Int(app_id)!,
            data: data
        )
        
//        do {
//            try await publishEvent()
//            //            try await publishEvent(channel: "emergencies", event: "sos", data: ["test": "some value"])
//        } catch {
//            print("Error", error.localizedDescription)
//        }
        
        //        chan?.trigger(eventName: "sos", data: ["test": "some value"])
    }
    
    func subscribeToEmergencies() {
        // callback for member added event
        //        let onMemberAdded = { (member: PusherPresenceChannelMember) in
        //            print("Memeber", member)
        //        }
        
        
        // subscribe to a presence channel
        //        let myChannel = pusher.subscribe("emergencies", onMemberAdded: onMemberAdded)
        
        
        //        myChannel.add
        // triggers a client event on that channel
        //        chan.trigger(eventName: "sos", data: ["test": "some value"])
        
        // subscribe to a channel
        let myChannel = pusher.subscribe("emergencies")
        
        _ = myChannel.bind(eventName: "sos-start", eventCallback: { (event: PusherEvent) in
            print("Calling back")
            
            // TODO: - Make sure not the sender
            
            // convert the data string to type data for decoding
            guard let json: String = event.data,
                  let jsonData: Data = json.data(using: .utf8)
            else {
                print("Could not convert JSON string to data", event.data)
                return
            }
            
            // decode the event data as json into a DebugConsoleMessage
            let decodedMessage = try? self.decoder.decode(SOSEmergency.self, from: jsonData)
            guard let message = decodedMessage else {
                print("Could not decode message")
                return
            }
            
            print("\(message.title) says \(message.description)")
            self.audioManager.startAudio()
        })
        
        _ = myChannel.bind(eventName: "sos-end", eventCallback: { (event: PusherEvent) in
            print("Calling end")
            self.audioManager.stopAudio()
        })
        
    }
}


class AuthRequestBuilder: AuthRequestBuilderProtocol {
    func requestFor(socketID: String, channelName: String) -> URLRequest? {
        var request = URLRequest(url: URL(string: "http://localhost:9292/pusher/auth")!)
        request.httpMethod = "POST"
        request.httpBody = "socket_id=\(socketID)&channel_name=\(channelName)".data(using: String.Encoding.utf8)
        return request
    }
}

struct DebugConsoleMessage: Codable {
    let name: String
    let message: String
}

extension Dictionary {
    func jsonString() -> String {
        let data = try! JSONSerialization.data(withJSONObject: self, options: [])
        return String(data: data, encoding: .utf8)!
    }
}

struct MyPusherEvent: Encodable {
    let name: String
    let channels: [String]
    let data: SOSEmergency
}

struct SOSEmergency: EmergencyAlert {
    var id: UUID = UUID()
    
    var title: String
    
    var description: String
    
    var sender: KBUserShort
    
    
}
protocol EmergencyAlert: Codable {
    var id: UUID { get }
    var title: String { get }
    var description: String { get }
    var sender: KBUserShort { get }
}


