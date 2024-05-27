//
//  KBPusherManager.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 27/05/2024.
//

import Foundation
import PusherSwift

class KBPusherManager: NSObject, PusherDelegate {
    private var pusher: Pusher! = nil
    private let decoder = JSONDecoder()
    
    static let shared = KBPusherManager()

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
        
        
        let app_id = "962207"
        let key = "fd4d4731402adac340ad"
        let secret = "fd97f4ac7fddf699759d"
        let cluster = "ap2"
        
        // Only use your secret here for testing or if you're sure that there's
        // no security risk
        let options = PusherClientOptions(host: .cluster(cluster))
        let pusherClientOptions = PusherClientOptions(authMethod: .inline(secret: secret))
        pusher = Pusher(key: key, options: options)
        
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
        
        // callback for member added event
        let onMemberAdded = { (member: PusherPresenceChannelMember) in
            print("Memeber", member)
        }
        
        // subscribe to a presence channel
        let chan = pusher.subscribe("presence-channel", onMemberAdded: onMemberAdded)
        
        // triggers a client event on that channel
        chan.trigger(eventName: "client-test", data: ["test": "some value"])
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
