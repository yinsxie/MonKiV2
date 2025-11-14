//
//  CashierViewModel.swift
//  MonKiV2
//
//  Created by William on 14/11/25.
//

import SwiftUI

@Observable
final class CashierViewModel {
    weak var parent: PlayViewModel?

    init(parent: PlayViewModel?) {
        self.parent = parent
    }
    
    var checkOutItems: [CartItem] = []
    
    func addToCounter(_ item: CartItem) {
        checkOutItems.append(item)
    }
    
    func removeFromCounter(withId id: UUID) {
        checkOutItems.removeAll { $0.id == id }
    }
    
    func counterContainsItem(withId id: UUID) -> Bool {
        return checkOutItems.contains { $0.id == id }
    }
}
