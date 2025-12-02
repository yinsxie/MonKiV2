//
//  HelperScreenRoute.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import SwiftUI

enum HelperScreenRoute {
    case startingPage
    case dishBook
    case pickChef
    case multiplayerLobby
}

extension HelperScreenRoute: SubRouteProtocol {
    @ViewBuilder
    func delegateView() -> some View {
        switch self {
        case .startingPage:
            StartingPageView()
        case .dishBook:
            DishBookView()
        case .pickChef:
            PickChefView()
        case .multiplayerLobby:
            MultiplayerLobbyView()
        }
    }
}
