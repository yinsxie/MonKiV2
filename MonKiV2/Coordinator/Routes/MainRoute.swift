//
//  MainRoute.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import SwiftUI

enum MainRoute {
    case home
}


extension MainRoute: SubRouteProtocol {
    @ViewBuilder
    func delegateView() -> some View {
        switch self {
        case .home:
            HomeView()
        }
    }
}

