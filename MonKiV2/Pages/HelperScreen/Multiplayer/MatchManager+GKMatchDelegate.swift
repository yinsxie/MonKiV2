//
//  MatchManager+GKMatchDelegate.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 25/11/25.
//

import GameKit
import SwiftUI

extension MatchManager: GKMatchDelegate {
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        switch state {
        case .connected:
            print("\(player.displayName) has connected!")
            loadOpponentDetails(player: player)
        case .disconnected:
            print("\(player.displayName) disconnected")
            DispatchQueue.main.async {
                self.matchState = .idle
            }
        default:
            break
        }
    }
    
    func match(_ match: GKMatch, didFailWithError error: Error?) {
        print("Match failed: \(error?.localizedDescription ?? "Unknown")")
    }
    
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        // 1. Check for handshake
        if let str = String(data: data, encoding: .utf8), str == "READY" {
            print("Opponent is Ready")
            DispatchQueue.main.async {
                self.isRemotePlayerReady = true
                self.checkIfGameCanStart()
            }
            return
        }
        
        // 2. Decode Game Packet
        do {
            let packet = try JSONDecoder().decode(GamePacket.self, from: data)
            print("📦 [Receiver] Received Packet: \(packet.type) | Item: \(packet.itemName)")
            
            // 3. Forward to PlayViewModel via Delegate
            DispatchQueue.main.async {
                switch packet.type {
                case .itemPurchased:
                    self.delegate?.didRemotePlayerPurchase(itemName: packet.itemName)
                case .itemAddedToDish:
                    self.delegate?.didRemotePlayerAddToDish(itemName: packet.itemName)
                case .itemRemovedFromDish:
                    self.delegate?.didRemotePlayerRemoveFromDish(itemName: packet.itemName)
                }
            }
        } catch {
            print("❌ Failed to decode packet: \(error)")
        }
    }
}
