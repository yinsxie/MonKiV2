//
//  MatchManager+GKMatchDelegate.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 25/11/25.
//

import GameKit
import SwiftUI

extension MatchManager: GKMatchDelegate {
    // MARK: - Connection and Error Handling (Low Complexity)
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        switch state {
        case .connected:
            print("👤 \(player.displayName) has connected!")
            loadOpponentDetails(player: player)
        case .disconnected:
            print("🔌 \(player.displayName) disconnected")
            DispatchQueue.main.async {
                self.matchState = .idle
            }
        default:
            break
        }
    }
    
    func match(_ match: GKMatch, didFailWithError error: Error?) {
        print("❌ Match failed: \(error?.localizedDescription ?? "Unknown")")
    }
    
    // MARK: - Data Reception (Refactored)
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        // 1. Check for simple handshake
        if let str = String(data: data, encoding: .utf8), str == "READY" {
            print("🤝 Opponent is Ready")
            Task { @MainActor in
                self.isRemotePlayerReady = true
                self.checkIfGameCanStart()
            }
            return
        }
        
        // 2. Decode and Handle Game Packet (Delegated off main thread)
        Task {
            do {
                let packet = try JSONDecoder().decode(GamePacket.self, from: data)
                if packet.type == .sendDishImageData {
                    print("🏷️ [Receiver] Packet Type: \(packet.type) | Image Data Size: \(packet.imagePayLoad?.payload.count ?? 0) bytes")
                }
                else {
                    print("📦 [Receiver] Received Packet: \(packet.type) | Item: \(packet.itemName ?? "N/A")")
                }
                // Delegate packet handling back to the main actor
                self.handleGamePacket(packet, fromRemotePlayer: player)
                
            } catch {
                print("❌ Failed to decode packet: \(error)")
                print("Trying chunking system...")
            }
        }
    }
    
    // MARK: - Private Packet Handling (High Complexity Concentrated Here)
    @MainActor
    private func handleGamePacket(_ packet: GamePacket, fromRemotePlayer player: GKPlayer) {
        
        // Helper function to safely extract itemName and call the corresponding delegate method
        func handleItemNamePacket(_ delegateAction: (String) -> Void) {
            if let name = packet.itemName {
                delegateAction(name)
            }
        }
        
        switch packet.type {
        case .itemPurchased:
            handleItemNamePacket { self.delegate?.didRemotePlayerPurchase(itemName: $0) }
            
        case .itemAddedToDish:
            handleItemNamePacket { self.delegate?.didRemotePlayerAddToDish(itemName: $0) }
            
        case .itemRemovedFromDish:
            handleItemNamePacket { self.delegate?.didRemotePlayerRemoveFromDish(itemName: $0) }
            
        case .receiptItemDragged:
            handleItemNamePacket { self.delegate?.didRemotePlayerDragReceiptItem(itemName: $0) }
            
        case .receiptItemCancelled:
            handleItemNamePacket { self.delegate?.didRemotePlayerCancelReceiptItem(itemName: $0) }
            
        case .createDishItemDragged:
            handleItemNamePacket { self.delegate?.didRemotePlayerDragCreateDishItem(itemName: $0) }
            
        case .createDishItemCancelled:
            handleItemNamePacket { self.delegate?.didRemotePlayerCancelCreateDishItem(itemName: $0) }
            
        case .budgetEvent:
            if let payload = packet.budgetPayload {
                self.delegate?.didReceiveBudgetEvent(payload)
            }
            
        case .sendDishImageData:
            if let payload = packet.imagePayLoad {
                receiver.handleIncoming(payload)
            }
            
        case .createDishPlayerReady:
            self.delegate?.didRemotePlayerReadyInCreateDish()
            
        case .createDishPlayerUnready:
            self.delegate?.didRemotePlayerUnreadyInCreateDish()
            
        case .sendShowMultiplayerDish:
            self.delegate?.didReceiveShowMultiplayerDish()
        
        case .sendHideMultiplayerDish:
            self.delegate?.didReceiveHideMultiplayerDish()
            
        case .sendToggleReadyToSaveDishImage:
            self.delegate?.didReceiveToggleReadyToSaveDishImage()
        }
    }
}
