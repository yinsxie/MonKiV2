//
//  Player.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import SwiftUI
import Combine

struct Player {
    var playerId: UUID
    
    // TODO: Replace with Game Center ID after gamekit is established
    var gameKitId: UUID
    var displayName: String
    
    static let mockPlayer = Player(
        playerId: UUID(),
        gameKitId: UUID(),
        displayName: "Mock Player"
    )
}
