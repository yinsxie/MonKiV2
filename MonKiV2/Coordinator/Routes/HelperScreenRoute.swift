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
}

extension HelperScreenRoute: SubRouteProtocol {
    @ViewBuilder
    func delegateView() -> some View {
        switch self {
        case .startingPage:
            StartingPageView()
        case .dishBook:
            DishBookView()
        }
    }
}
