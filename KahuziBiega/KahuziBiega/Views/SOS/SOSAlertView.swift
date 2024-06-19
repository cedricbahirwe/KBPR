//
//  SOSAlertView.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 06/06/2024.
//

import SwiftUI
import AVFoundation

enum SOSAlertCreator: Identifiable {
    var id: UUID {
        switch self {
        case .me(let id):
            return id
        case .other(let user):
            return user.id
        }
    }
    
    case me(id: UUID = UUID()), other(KBUserShort)
}

struct SOSAlertView: View {
    var creator: SOSAlertCreator
    private var isReceiver: Bool {
        if case .other = creator { return true } else { return false }
    }
    
    var onCancel: () -> Void
    var onRespond: () -> Void
    private let audioManager = AudioManager()
    var body: some View {
        VStack {
            Spacer()
            
            Text("SOS Alert")
                .font(.largeTitle.bold())
            
            Text(isReceiver ? "Emergency Notification Received" : "Notifying...")
                .foregroundStyle(.red)
                .opacity(0.75)
            
            Spacer()
            
            Image(.sosBell)
                .resizable()
                .scaledToFit()
            
            Spacer()
            
            Group {
                if case let .other(user) = creator {
                    VStack(alignment: .leading) {
                        Text("Alert By: \(user.firstName) \(user.lastName)")
                        Text("Badge Number: \(user.badgeNumber)")
                        if let coordinate = user.gps {
                            Text("Coordinate: \(coordinate.latitude.formatted()), \(coordinate.longitude.formatted())")
                        }
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                } else {
                    Text("Stay where you are, SOS\nResponders will be notified of your location.")
                }
            }
            .font(.title2)
            .frame(maxWidth: .infinity, alignment: .leading)

           
            
            Spacer()
            
            VStack(spacing: 15) {
                
                if isReceiver {
                    Button(action: {
                        onRespond()
                    }) {
                        Text("Respond")
                            .foregroundStyle(.white)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(.tint, in: .capsule)
                    }
                }
                
                Button(action: {
                    onCancel()
                    if !isReceiver {
                        KBPusherManager.shared.stopSOSEvent()
                    }
                }) {
                    Text(isReceiver ? "Ignore Alert" : "Cancel Alert")
                        .foregroundStyle(.white)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(.red, in: .capsule)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black, ignoresSafeAreaEdges: .all)
        .foregroundStyle(.white)
        .task {
            if !isReceiver {
#if !targetEnvironment(simulator)
                audioManager.startAudio()
#endif
                KBPusherManager.shared.publishSOSEvent()
            }
        }
    }
}

#Preview { //}(traits: .sizeThatFitsLayout) {
    SOSAlertView(creator: .me(), onCancel: {}, onRespond: {})
}


struct SOSPopupView: View {
    var onCancel: () -> Void
    var onActivate: () -> Void
    var body: some View {
        VStack(spacing: -60) {
            Color.red
                .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
                .frame(height: 70)
            
            
            VStack {
                Image(.sosBell)
                    .resizable(capInsets: .init(top: -20, leading: 0, bottom: 0, trailing: 0))
                    .frame(width: 80, height: 80)
                    .scaleEffect(1.2)
                    .background(.white, in: .circle)
                
                Text("Activate")
                    .textCase(.uppercase)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.red)
                
                VStack {
                    Text("You are about to activate SOS.")
                    Text("Park Rangers & management will be contacted.")
                    
                    Text("Your current location will be shared.")
                }
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.85)
                .padding(.vertical, 4)
                
                HStack(spacing: 30) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .foregroundStyle(.accent)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.accent, lineWidth: 1.0)
                            }
                    }
                    
                    
                    Button(action: onActivate) {
                        Text("Activate SOS")
                            .underline()
                            .foregroundStyle(.white)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(.red, in: .rect(cornerRadius: 8))
                    }
                }
            }
            .padding()
        }
        .background(.background.shadow(.drop(radius: 3)), in: .rect(cornerRadius: 16))
        .padding()
    }
}


import MediaPlayer

private extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
    }
}

class AudioManager: NSObject, AVAudioPlayerDelegate {
    static let shared = AudioManager()
    private var audioPlayer: AVAudioPlayer!
    
    override init() {
        super.init()
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            
            ()
        } catch {
            print("Failed to set audio session category: \(error.localizedDescription)")
        }
    }
    
    func startAudio() {
        playAlarmSound()
    }
    
    func stopAudio() {
        self.audioPlayer?.stop()
        self.audioPlayer = nil
    }
    
    private func playAlarmSound() {
        do {
            let alarmSoundURL = URL(filePath: Bundle.main.path(forResource: "alarm", ofType: "wav")!)
            self.audioPlayer =  try AVAudioPlayer(contentsOf: alarmSoundURL)
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.delegate = self
            self.audioPlayer.numberOfLoops = -1 // indefinitely playing
            self.audioPlayer.play()
            
            MPVolumeView.setVolume(0.8) // 80 %
            
        } catch {
            print("Failed to initialize AVAudioPlayer: \(error.localizedDescription)")
        }
    }
}
