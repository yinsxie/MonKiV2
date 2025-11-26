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
                    if let name = packet.itemName {
                        self.delegate?.didRemotePlayerPurchase(itemName: name)
                    }
                    
                case .itemAddedToDish:
                    if let name = packet.itemName {
                        self.delegate?.didRemotePlayerAddToDish(itemName: name)
                    }
                    
                case .itemRemovedFromDish:
                    if let name = packet.itemName {
                        self.delegate?.didRemotePlayerRemoveFromDish(itemName: name)
                    }
                    
                case .budgetEvent:
                    // NEW: Handle the budget payload
                    if let payload = packet.budgetPayload {
                        self.delegate?.didReceiveBudgetEvent(payload)
                    }
                }
            }
        } catch {
            print("❌ Failed to decode packet: \(error)")
        }
    }
}
