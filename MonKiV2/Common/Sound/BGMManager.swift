//
//  BGMManager.swift
//  MonKiV2
//
//  Created by Amelia Morencia Irena on 22/11/25.
//

import AVFoundation
import Foundation
import Combine

enum BGMTrack: String {
    case supermarket = "BGM_Supermarket"
}

final class BGMManager: ObservableObject {
    static let shared = BGMManager()
    
    private var player: AVAudioPlayer?
    private var isPlaying: Bool {
        player?.isPlaying == true
    }
    @Published var isMuted = false
    
    private init() {}
    
    func play(track: BGMTrack, volume: Float = 0.3) {
        if isPlaying { return }
        
        guard !isMuted else { return }
        
        stop()
        
        guard let url = Bundle.main.url(forResource: track.rawValue, withExtension: "mp3") else { return }
        
        do {
            let playerInstance = try AVAudioPlayer(contentsOf: url)
            playerInstance.numberOfLoops = -1
            playerInstance.volume = volume
            playerInstance.prepareToPlay()
            playerInstance.play()
            self.player = playerInstance
        } catch {
            print("Failed to play BGM: \(error)")
        }
    }
        
        func stop() {
            player?.stop()
            player = nil
        }

        func mute(_ mute: Bool) {
            isMuted = mute
            if mute {
                player?.volume = 0
            } else {
                player?.volume = 0.5
            }
        }
    
}
