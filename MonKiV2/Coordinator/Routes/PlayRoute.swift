//
//  MainRoute.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import SwiftUI

enum PlayRoute {
    case play
    case multiplayer(MatchManager)
}

extension PlayRoute: SubRouteProtocol {
    @ViewBuilder
    func delegateView() -> some View {
        switch self {
        case .play:
            PlayViewContainer(forGameMode: .singleplayer)
        case .multiplayer(let manager):
            PlayViewContainer(forGameMode: .multiplayer, matchManager: manager)
        }
    }
}
