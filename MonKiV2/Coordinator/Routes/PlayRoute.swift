//
//  MainRoute.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import SwiftUI

enum PlayRoute {
//    case play
    case singlePlayer(chef: ChefType)
    case multiplayer
}

extension PlayRoute: SubRouteProtocol {
    @ViewBuilder
    func delegateView() -> some View {
        switch self {
//        case .play:
//            PlayViewContainer(forGameMode: .singleplayer)
        case .singlePlayer(let chef):
            PlayViewContainer(forGameMode: .singleplayer, chef: chef)
            
        case .multiplayer:
            PlayViewContainer(forGameMode: .multiplayer)
        }
    }
}
