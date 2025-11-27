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
    private var checkoutTask: Task<Void, Never>?
    private var currentCheckoutID: UUID = UUID()
    var discardedAmountTracker: Int = 0
    var isScanning: Bool = false
    
    init(parent: PlayViewModel?) {
        self.parent = parent
        
        // MARK: Get 1 rice by default (temporary implementation since we only have 1 type of chef for now)
        if let riceItem = Item.items.first(where: { $0.name == "Rice" }) {
            let riceCartItem = CartItem(item: riceItem)
            self.purchasedItems.append(riceCartItem)
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
    
    var receivedMoneyGrouped: [MoneyGroup] {
        var temp: [Currency: (money: Money, count: Int)] = [:]
        
        for money in receivedMoney {
            if let existing = temp[money.currency] {
                temp[money.currency] = (existing.money, existing.count + 1)
            } else {
                temp[money.currency] = (money, 1)
            }
        }
        
        let res = temp.values
            .map { MoneyGroup(money: $0.money, count: $0.count) }
            .sorted { $0.money.currency.value > $1.money.currency.value } // Sort by count descending
        
        return res
    }
    
    var returnedMoney: [Money] = []
    var isAnimatingReturnMoney: Bool = false
    var isReturnedMoneyPrompted: Bool = false
    var isStartingReturnMoneyAnimation: Bool = false
    var isPlayerDisabledNavigatingWhileReceivedMoney: Bool = false
    private var tempPendingReturn: Int = 0
    var cumulativeReturnTotal: Int = 0
    
    func addReturnedMoney(_ currencies: [Currency]) {
        for currency in currencies {
            let newMoney = Money(forCurrency: currency)
            returnedMoney.append(newMoney)
            print("Money added to wallet: \(currency.value) (Instance ID: \(newMoney.id))")
        }
    }
    
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
    
    let maxItemsInCounter: Int = 12
    
    func addToCounter(_ item: CartItem) {
        if checkoutTask != nil || bagOffset > 0 {
            print("User scan barang saat animasi jalan -> Reset Tas")
            checkoutTask?.cancel()
            checkoutTask = nil
            finalizePurchase(instantReset: true)
        }
        
        checkOutItems.append(item)
        bagVisualItems.append(item)
        triggerScanEffect()
    }
    
    private func triggerScanEffect() {
        isScanning = false
        
        Task { @MainActor in
            isScanning = true
            
            try? await Task.sleep(nanoseconds: 300_000_000)
            
            isScanning = false
        }
    }
    
    func removeFromCounter(withId id: UUID) {
        checkOutItems.removeAll { $0.id == id }
        bagVisualItems.removeAll { $0.id == id }
    }
    
    func popFromCounter(withId id: UUID) -> CartItem? {
        let item = checkOutItems.first { $0.id == id }
        checkOutItems.removeAll { $0.id == id }
        bagVisualItems.removeAll { $0.id == id }
        return item
    }
    
    func counterContainsItem(withId id: UUID) -> Bool {
        return checkOutItems.contains { $0.id == id }
    }
    
    func isLimitCounterReached() -> Bool {
        return getCounterItemsCount() >= maxItemsInCounter
    }
    
    func onReturnedReceivedMoneyTapped() {
        DispatchQueue.main.async {
            self.parent?.walletVM.moneys.append(contentsOf: self.returnedMoney)
            self.returnedMoney.removeAll()
        }
    }
    
    func onPageChangeWhileReceivedMoney() {
        DispatchQueue.main.async {
            self.parent?.walletVM.moneys.append(contentsOf: self.receivedMoney)
            self.receivedMoney.removeAll()
        }
    }
    
    func onReturnedMoneyTapped() {
        // floating feedback
        let totalAmount = returnedMoney.reduce(0) { $0 + $1.currency.value }
        self.tempPendingReturn = totalAmount
        
        DispatchQueue.main.async {
            self.parent?.walletVM.moneys.append(contentsOf: self.returnedMoney)
            self.returnedMoney.removeAll()
        }
        
        // TODO: animate flying money to wallet before removing the overlay
        
        withAnimation {
            isReturnedMoneyPrompted = false
            isStartingReturnMoneyAnimation = false
        }
        
        checkOutSuccess()
    }
    
    func checkOutSuccess() {
        let itemsToCheckout = self.checkOutItems
        guard !itemsToCheckout.isEmpty else { return }
        
        let newTransactionID = UUID()
        self.currentCheckoutID = newTransactionID
        
        if checkoutTask != nil || bagOffset > 0 {
            checkoutTask?.cancel()
            checkoutTask = nil
            
            if !bagVisualItems.isEmpty {
                let oldItems = bagVisualItems.filter { oldItem in
                    !itemsToCheckout.contains(where: { $0.id == oldItem.id })
                }
                let itemsToSave = oldItems.map { CartItem(item: $0.item) }
                purchasedItems.append(contentsOf: itemsToSave)
            }
            
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                self.bagOffset = 0
            }
        }
        
        self.bagVisualItems = itemsToCheckout
        
        self.checkOutItems.removeAll()
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            self.parent?.walletVM.isWalletOpen = false
        }
        
        checkoutTask = Task { @MainActor in
            let myID = newTransactionID
            
            if Task.isCancelled { return }
            
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                guard self.currentCheckoutID == myID else { return }
                
                withAnimation(.easeIn(duration: 0.8)) {
                    self.bagOffset = 1000
                }
                
                try await Task.sleep(nanoseconds: 800_000_000)
                guard self.currentCheckoutID == myID else { return }
                
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
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                self.bagOffset = 0
            }
        } else {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                self.bagOffset = 0
            }
        }
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            self.parent?.walletVM.isWalletOpen = true
        }
        
        // floating feedback
        if self.tempPendingReturn > 0 {
            withAnimation {
                self.cumulativeReturnTotal += self.tempPendingReturn
            }
            self.tempPendingReturn = 0
        }
    }
}

private extension CashierViewModel {
    func getCounterItemsCount() -> Int {
        return checkOutItems.count
    }
}
