//
//  PlayerSessionData.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import Foundation
import Combine

enum GamePlayerState {
    case budgeting
    case roaming
    case checkout
}

final class PlayerSessionData: ObservableObject {
    var playerSessionId: UUID
    var player: Player
    
    @Published var playerState: GamePlayerState
    @Published var currentBudget: Int
    @Published var cart: PlayerCartItem
    
    init(player: Player, withState state: GamePlayerState = .budgeting, budget: Int, cart: PlayerCartItem = PlayerCartItem(items: [])) {
        self.playerSessionId = UUID()
        self.player = player
        
        self.playerState = .budgeting
        self.currentBudget = budget
        self.cart = cart
    }
}
