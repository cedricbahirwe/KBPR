//
//  KBPusherClient.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 18/06/2024.
//

import Foundation
import Pusher

final class KBPusherClient {
    private let pusher: Pusher
    
    // Generated using: openssl rand -base64 32
    private let encryptionMasterKey = "utqWjJs+3Sigm7RctlV0G61QKvECpSYMsgFPwgbvsRc="

    init(_ cluster: String, secret: String, key: String, appId: Int) {
        self.pusher = Pusher(options: try! PusherClientOptions(
            appId: appId,
            key: key,
            secret: secret,
            encryptionMasterKey: encryptionMasterKey,
            cluster: cluster))
    }
    
    func triggerEvent<T>(event: KBPusherEvent<T>) {
        let publicChannel = Channel(name: event.channel.rawValue, type: .public)
        let publicEvent = try! Event(name: event.name.rawValue,
                                     data: event.data,
                                     channel: publicChannel)
        
        pusher.trigger(event: publicEvent) { result in
            switch result {
            case .success(let channelSummaries):
                print("Summaries", channelSummaries)
            case .failure(let error):
                print("Error", error.localizedDescription)
            }
        }
    }
    
    func stopEvent() {
        
        let publicChannel = Channel(name: KBPusherChannelName.emergencies.rawValue, type: .public)
        let publicEvent = try! Event(name: KBPusherEventName.sosEnd.rawValue, 
                                     data: "",
                                     channel: publicChannel)
        
        pusher.trigger(event: publicEvent) { result in
            switch result {
            case .success(let channelSummaries):
                print("Summaries", channelSummaries)
            case .failure(let error):
                print("Error", error.localizedDescription)
            }
        }
    }
    
}
