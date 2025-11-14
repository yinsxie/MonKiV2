//
//  GameSessionData.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import Foundation
import Combine

enum GameSessionType {
    case singlePlayer
    case multiPlayer
}

// MARK: - Game Session Data
// TODO: Change if multi-player is implemented (semoga bgt gk rombak)
final class GameSessionData: ObservableObject {
    var sessionID: UUID
    
    @Published var budget: Int
    @Published var players: [PlayerSessionData]
    @Published var purchasedItems: [PurchasedItem]
    @Published var checkoutItems: [CheckoutItem]
     
    var createdAt: Date
     
    init(forGameMode type: GameSessionType) {
        self.sessionID = UUID()
        
        let budget = GameSessionData.generateBudget(min: 5000, max: 20000, step: 1000)
        self.budget = budget
        
        let player = Player.mockPlayer
        let playerSessionData = PlayerSessionData(player: player, budget: budget)
        let purchasedItems: [PurchasedItem] = []
        let checkoutItems: [CheckoutItem] = []
        
        self.players = [playerSessionData]
        self.purchasedItems = purchasedItems
        self.checkoutItems = checkoutItems
        
        self.createdAt = Date()
    }
}

extension GameSessionData {
    static func generateBudget(min: Int, max: Int, step: Int) -> Int {
        let range = stride(from: min, through: max, by: step).map { $0 }
        return range.randomElement() ?? min
    }
}
