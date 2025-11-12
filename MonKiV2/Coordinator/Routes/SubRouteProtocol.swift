//
//  SubRouteProtocol.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import SwiftUI

protocol SubRouteProtocol: Hashable {
    associatedtype Body: View
    @ViewBuilder
    func delegateView() -> Body
}
