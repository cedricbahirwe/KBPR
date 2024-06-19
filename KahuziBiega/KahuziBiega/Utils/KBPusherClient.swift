//
//  KBPusherClient.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 18/06/2024.
//

import Foundation
import Pusher

final class KBPusherClient {
    static let shared = KBPusherClient()
    private var pusher: Pusher! = nil

    private init() { }
    
    func triggerEvent(_ cluster: String, secret: String, key: String, appId: Int, data: SOSEmergency) {

        self.pusher = Pusher(options: try! PusherClientOptions(appId: appId,
                                                              key: key,
                                                              secret: secret,
                                                              encryptionMasterKey: "utqWjJs+3Sigm7RctlV0G61QKvECpSYMsgFPwgbvsRc=",
                                                              cluster: cluster))
        
        let publicChannel = Channel(name: "emergencies", type: .public)
        let publicEvent = try! Event(name: "sos-start",
                                     data: data,
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
        
        let publicChannel = Channel(name: "emergencies", type: .public)
        let publicEvent = try! Event(name: "sos-end", 
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
