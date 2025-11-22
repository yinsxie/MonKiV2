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
    private var checkoutTask: Task<Void, Never>?
    
    init(parent: PlayViewModel?) {
        self.parent = parent
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
    var bagVisualItems: [CartItem] = []
    
    var bagOffset: CGFloat = 0
    var bagOpacity: Double = 1.0
    
    var purchasedItemVisualized: [CartItem] {
        let items = purchasedItems
        
        if items.count > 12 {
            return Array(items.suffix(12))
        }
        
        return items
    }
    
    let maxItemsInCounter: Int = 6
    
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
        guard !checkOutItems.isEmpty else { return }
        
        if checkoutTask != nil || !bagVisualItems.isEmpty {
            
            checkoutTask?.cancel()
            checkoutTask = nil
            finalizePurchase(instantReset: true)
            
            Task { @MainActor in
                self.parent?.walletVM.isWalletOpen = false
            }
        }
        
        self.bagVisualItems = self.checkOutItems
        self.checkOutItems.removeAll()
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            self.parent?.walletVM.isWalletOpen = false
        }
        
        checkoutTask = Task { @MainActor in
            if Task.isCancelled { return }
            
            do {
                try await Task.sleep(nanoseconds: 1_500_000_000)
                if Task.isCancelled { return }
                
                try await Task.sleep(nanoseconds: 500_000_000)
                if Task.isCancelled { return }
                
                withAnimation(.easeIn(duration: 0.8)) {
                    self.bagOffset = 1000
                }
                
                try await Task.sleep(nanoseconds: 800_000_000)
                if Task.isCancelled { return }
                
                self.finalizePurchase()
                
            } catch {
                print("Task checkout baru dibatalkan (mungkin user checkout lagi).")
            }
        }
    }
    
    private func finalizePurchase(instantReset: Bool = false) {
        guard !bagVisualItems.isEmpty else { return }
        
        let freshItems = self.bagVisualItems.map { CartItem(item: $0.item) }
        self.purchasedItems.append(contentsOf: freshItems)
        self.bagVisualItems.removeAll()
        
        if instantReset {
            self.bagOffset = 0
        } else {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                self.bagOffset = 0
            }
        }
    }
}

private extension CashierViewModel {
    func getCounterItemsCount() -> Int {
        return checkOutItems.count
    }
}
