//
//  PlayerCartItem.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import SwiftUI
import Combine

final class PlayerCartItem: ObservableObject {
    @Published var items: [Item]
    
    init(items: [Item]) {
        self.items = items
    }
}
