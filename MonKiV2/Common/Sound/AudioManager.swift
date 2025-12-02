//
//  AudioManager.swift
//  MonKiV2
//
//  Created by Amelia Morencia Irena on 16/11/25.
//

import AVFoundation
import Foundation

enum Sound: String, CaseIterable {
    case buttonClick
    case dishDone
    case dropItemCart
    case dropItemTrash
    case paymentSuccess
    case pickShelf
    case scanItem
    case dropFail
    case zoomInATM
    case beepATM
    case pageTurn
    case loadCooking
    case changeSound
    case wind
    case openFridge
    case closeFridge
}

final class AudioManager {
    static let shared = AudioManager()
    
    private var players: [AVAudioPlayer] = []
    private var isMuted = false
    
    private init() {
        preloadAll()
    }
    
    // MARK: - Preload
    private func preloadAll() {
        Sound.allCases.forEach { sound in
            _ = loadPlayer(for: sound.rawValue)
        }
    }
    
    private func loadPlayer(for name: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("Sound not found: \(name)")
            return nil
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            return player
        } catch {
            print("Failed preload: \(error)")
            return nil
        }
    }
    
    // MARK: - Play SFX
    func play(_ sound: Sound,
              volume: Float = 1.0,
              pitchVariation: Float = 0.0) {
        
        guard !isMuted else { return }
        
        guard let url = Bundle.main.url(
            forResource: sound.rawValue,
            withExtension: "mp3"
        ) else { return }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            
            if pitchVariation > 0 {
                let randomPitch = 1.0 + Float.random(in: -pitchVariation...pitchVariation)
                player.enableRate = true
                player.rate = randomPitch
            }
            
            player.prepareToPlay()
            player.play()
            
            players.append(player)
            
            players = players.filter { $0.isPlaying }
            
        } catch {
            print("Failed to play \(sound.rawValue)")
        }
    }
    
    // MARK: - Loop (Ambience / Music)
    func playLoop(_ sound: Sound, volume: Float = 0.6) {
        guard let url = Bundle.main.url(
            forResource: sound.rawValue,
            withExtension: "mp3"
        ) else { return }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = volume
            player.prepareToPlay()
            player.play()
            players.append(player)
        } catch {
            print("Failed to loop: \(sound.rawValue)")
        }
    }
    
    // MARK: - Mute
    func setMuted(_ mute: Bool) {
        isMuted = mute
        players.forEach { $0.volume = mute ? 0 : 1 }
    }
    
    func stop(_ sound: Sound) {
        players = players.filter { player in
            if player.url?.lastPathComponent == "\(sound.rawValue).mp3" {
                player.stop()
                return false
            }
            return true
        }
    }
    
}
