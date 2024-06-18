//
//  SOSAlertView.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 06/06/2024.
//

import SwiftUI
import AVFoundation

struct SOSAlertView: View {
    var onCancel: () -> Void
    @State var audioPlayer: AVAudioPlayer!
    let audioDelegate = AudioDelegate()
    var body: some View {
        VStack {
            Spacer()
            
            Text("SOS Alert")
                .font(.largeTitle.bold())
                .foregroundStyle(.thickMaterial)
            
            Text("Notifying...")
                .foregroundStyle(.red)
                .opacity(0.75)
            
            Spacer()
            
            Image(.sosBell)
                .resizable()
                .scaledToFit()
            
            Spacer()
            
            Text("Stay where you are, SOS\nResponders will be notified of your location.")
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Button(action: {
                onCancel()
            }) {
                Text("Cancel Alert")
                    .foregroundStyle(.white)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(.red, in: .capsule)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black, ignoresSafeAreaEdges: .all)
        .foregroundStyle(.white)
        .task {
            do {
                AVAudioSession.sharedInstance().outputVolume 
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(.playback, mode: .default)
                try audioSession.setActive(true)
//                try audioSession.setVolume(1.0, options:.notifyOthersOnDeactivation)

                
                playAlarmSound()
            } catch {
                print("Failed to set audio session category: \(error.localizedDescription)")
            }
        }
    }
    
    private func playAlarmSound() {
        do {
            let alarmSoundURL = URL(filePath: Bundle.main.path(forResource: "alarm", ofType: "wav")!)
            self.audioPlayer =  try AVAudioPlayer(contentsOf: alarmSoundURL)
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.delegate = audioDelegate
            self.audioPlayer.numberOfLoops = -1 // indefinitely playing
            self.audioPlayer.play()
            
            MPVolumeView.setVolume(0.8) // 80 KB

        } catch {
            print("Failed to initialize AVAudioPlayer: \(error.localizedDescription)")
        }
    }
}

extension SOSAlertView {
    class AudioDelegate: NSObject, AVAudioPlayerDelegate {
        
    }
}

#Preview { //}(traits: .sizeThatFitsLayout) {
    SOSAlertView(onCancel: {})
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
