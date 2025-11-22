//
//  CashierViewModel.swift
//  MonKiV2
//
//  Created by William on 14/11/25.
//

import SwiftUI

enum CashierPage {
    case loading
    case payment
    case none
}

@Observable
final class CashierViewModel {
    weak var parent: PlayViewModel?
    
    init(parent: PlayViewModel?) {
        self.parent = parent
        
        // MARK: Get 1 rice by default (temporary implementation since we only have 1 type of chef for now)
        // TODO: Change carrot with rice after asset and shelf is implemented
        if let carrotItem = Item.items.first(where: { $0.name == "Carrot" }) {
            let carrotCartItem = CartItem(item: carrotItem)
            self.purchasedItems.append(carrotCartItem)
        }
    }
    
    var currentPage: CashierPage {
        if parent?.currentPageIndex == 2 {
            return .loading
        } else if parent?.currentPageIndex == 3 {
            return .payment
        } else {
            return .none
        }
    }
    
    var isPaymentSufficient: Bool {
        if let parent = parent {
            return parent.currentBudget >= totalPrice
        }
        return false
    }
    
    var totalPrice: Int {
        checkOutItems.reduce(0) { $0 + $1.item.price }
    }
    
    var receivedMoney: [Money] = []
    
    func acceptMoney(_ money: Money) {
        receivedMoney.append(money)
        print("Cashier received money: \(money.currency.value)")
    }
    
    var totalReceivedMoney: Int {
        receivedMoney.reduce(0) { $0 + $1.currency.value }
    }
    
    var checkOutItems: [CartItem] = []
    var purchasedItems: [CartItem] = []
    
    var purchasedItemVisualized: [CartItem] {
        // If item less or equal to 3, show all
        if purchasedItems.count <= 3 {
            return purchasedItems
        }

        var seenItemIDs = Set<UUID>()
        var result: [CartItem] = []

        // 1) Add up to 3 unique item types (preserving order)
        for cart in purchasedItems {
            if !seenItemIDs.contains(cart.item.id) {
                seenItemIDs.insert(cart.item.id)
                result.append(cart)
                if result.count == 3 { return result }
            }
        }

        // 2) If fewer than 3 unique types, fill with other CartItem instances
        for cart in purchasedItems {
            // skip ones already added (by cartItem id)
            if result.contains(where: { $0.id == cart.item.id }) { continue }
            result.append(cart)
            if result.count == 3 { break }
        }

        return result
    }
    
    let maxItemsInCounter: Int = 12
    
    func addToCounter(_ item: CartItem) {
        checkOutItems.append(item)
    }
    
    func removeFromCounter(withId id: UUID) {
        checkOutItems.removeAll { $0.id == id }
    }
    
    func popFromCounter(withId id: UUID) -> CartItem? {
        let item = checkOutItems.first { $0.id == id }
        checkOutItems.removeAll { $0.id == id }
        return item
    }
    
    func counterContainsItem(withId id: UUID) -> Bool {
        return checkOutItems.contains { $0.id == id }
    }
    
    func isLimitCounterReached() -> Bool {
        return getCounterItemsCount() >= maxItemsInCounter
    }
    
    func checkOutSuccess() {
        DispatchQueue.main.async {
            withAnimation {
                self.purchasedItems.append(contentsOf: self.checkOutItems)
                self.checkOutItems.removeAll()
            }
        }
    }
}

private extension CashierViewModel {
    func getCounterItemsCount() -> Int {
        return checkOutItems.count
    }
}
