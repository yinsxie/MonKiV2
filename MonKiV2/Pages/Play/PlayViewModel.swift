//
//  PlayViewModel.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//

import SwiftUI

@Observable class PlayViewModel {
    var floatingItems: [FloatingItemFeedback] = [] // track items that need animating floating item feedback
    var itemsCurrentlyAnimating: [UUID] = [] // tracks items that are animating but MUST become visible again (no fade)
    
    // Global Published Var for global state
    var initialBudget: Int = 0
    var currentBudget: Int {
        walletVM.moneys.reduce(0) { $0 + $1.currency.value } + cashierVM.totalReceivedMoney
    }
    
    // VM's
    var shelfVM: ShelfViewModel!
    var cartVM: CartViewModel!
    var cashierVM: CashierViewModel!
    var walletVM: WalletViewModel!
    var dishVM: CreateDishViewModel!
    var atmVM: ATMViewModel!
    
    var currentPageIndex: Int? = 0
    
    var dragManager = DragManager()
    
    var atmFrame: CGRect = .zero
    var walletFrame: CGRect = .zero
    
    var isFlyingMoney: Bool = false
    var flyingMoneyCurrency: Currency?
    
    init() {
        // On Game Start
        let budget = generateBudget(min: 30, max: 100, step: 10)
        self.initialBudget = budget
        
        self.shelfVM = ShelfViewModel(parent: self)
        self.cartVM = CartViewModel(parent: self)
        self.cashierVM = CashierViewModel(parent: self)
        self.walletVM = WalletViewModel(parent: self)
        self.dishVM = CreateDishViewModel(parent: self)
        self.atmVM = ATMViewModel(parent: self, initialBalance: budget)
        
        setupGameLogic()
        // MARK: - ini komen dulu supaya duitnya ga langsung masuk dompet
                let currencyBreakdown = Currency.breakdown(from: budget)
                walletVM.addMoney(currencyBreakdown)
    }
    
    private func setupGameLogic() {
        dragManager.onDropSuccess = { [weak self] zone, draggedItem in
            guard let self = self else { return }
            
            switch draggedItem.payload {
            case .grocery(let groceryItem):
                self.handleGroceryDrop(zone: zone, groceryItem: groceryItem, draggedItem: draggedItem)
            case .money(let currency):
                print("Dropped money with price: \(currency)")
                self.handleMoneyDrop(zone: zone, currency: currency, draggedItem: draggedItem)
            }
        }
        
        dragManager.onDropFailed = { [weak self] draggedItem in
            guard let self = self else { return }
            self.handleDropFailed(draggedItem: draggedItem)
        }
    }
    
    func clearVisualAnimationState(id: UUID, trackedItemID: UUID, wasFadingOut: Bool) {
        floatingItems.removeAll(where: { $0.id == id })
        
        if !wasFadingOut {
            itemsCurrentlyAnimating.removeAll(where: { $0 == trackedItemID })
        }
    }
    
    func removeFallingItem(id: UUID) {
        floatingItems.removeAll(where: { $0.id == id })
    }
    
    func onCancelPayment() {
        dropMoneyBackToWallet()
    }
    
    func triggerMoneyFlyAnimation(amount: Int) {
        print("PlayVM: start animasi uang masuk ke wallet untuk nominal \(amount)")
        
        let currency = Currency(value: amount)
        self.flyingMoneyCurrency = currency
        
        withAnimation(.easeInOut(duration: 0.1)) {
            self.isFlyingMoney = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }
            
            self.isFlyingMoney = false
            self.flyingMoneyCurrency = nil
            
            print("PlayVM: Animasi selesai. Add money to Wallet.")
            
            let breakdown = Currency.breakdown(from: amount)
            
            if breakdown.isEmpty {
                print("Breakdown currency kosong untuk amount \(amount)!")
            }
            
            Task { @MainActor in
                withAnimation {
                    self.walletVM.addMoney(breakdown)
                }
            }
        }
    }
}

// MARK: Drop Handlers
private extension PlayViewModel {
    
    func handleDropFailed(draggedItem: DraggedItem) {
        print("Drop failed (Invalid Zone). Clearing item without animation.")
        
        DispatchQueue.main.async {
            self.dragManager.currentDraggedItem = nil
        }
    }
    
    func handleGroceryDrop(zone: DropZoneType, groceryItem: Item, draggedItem: DraggedItem) {
        switch zone {
        case .cart:
            handleGroceryDropOnCart(groceryItem: groceryItem, draggedItem: draggedItem)
        case .cashierLoadingCounter:
            handleCashierOnLoadingCounter(groceryItem: groceryItem, draggedItem: draggedItem)
        case .cashierRemoveItem:
            handleGroceryDropOnRemoveZone(draggedItem: draggedItem)
        case .shelfReturnItem:
            handleGroceryDropOnShelf(draggedItem: draggedItem)
        case .createDish:
            handleGroceryDropOnCreateDish(groceryItem: groceryItem, draggedItem: draggedItem)
        case .createDishOverlay:
            handleGroceryDropOnCreateDishOverlay(groceryItem: groceryItem, draggedItem: draggedItem)
        default:
            DispatchQueue.main.async { self.dragManager.currentDraggedItem = nil }
        }
    }
    
    func handleMoneyDrop(zone: DropZoneType, currency: Currency, draggedItem: DraggedItem) {
        //        withAnimation(.spring) {
        switch zone {
        case .cashierPaymentCounter:
            print("Dropped money on payment counter")
            
            // Put money
            dropMoneyToCounter(withCurrency: currency)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.handleOnPaymentCounter()
            }
        case .wallet:
            handleMoneyDropOnWallet(currency: currency, draggedItem: draggedItem)
        default:
            print("Dropped money on an invalid zone (\(zone.rawValue))")
        }
        //        }
    }
    
    func dropMoneyToCounter(withCurrency currency: Currency) {
        if cashierVM.checkOutItems.isEmpty {
            return
        }
        DispatchQueue.main.async {
            self.cashierVM.acceptMoney(Money(forCurrency: currency))
            self.walletVM.removeFirstMoney(withCurrency: currency)
        }
    }
    
    func dropMoneyBackToWallet() {
        DispatchQueue.main.async {
            self.walletVM.moneys.append(contentsOf: self.cashierVM.receivedMoney)
            self.cashierVM.receivedMoney.removeAll()
        }
    }
    
    func handleGroceryDropOnCart(groceryItem: Item, draggedItem: DraggedItem) {
        
        if let source = draggedItem.source {
            switch source {
            case .cashierCounter:
                // from counter
                if self.cartVM.isFull {
                    self.cartVM.triggerShake()
                    print("Cart full, item not moved.")
                    AudioManager.shared.play(.dropFail)
                    
                    let fall = FloatingItemFeedback(
                        id: UUID(),
                        item: groceryItem,
                        startPoint: self.dragManager.currentDragLocation,
                        originPoint: self.dragManager.dragStartLocation,
                        shouldFadeOut: false, // NO FADE
                        trackedItemID: draggedItem.id
                    )
                    self.floatingItems.append(fall)
                    self.itemsCurrentlyAnimating.append(draggedItem.id) // Hide original item
                    self.dragManager.currentDraggedItem = nil
                    return
                }
                
                if let cartItem = self.cashierVM.popFromCounter(withId: draggedItem.id) {
                    DispatchQueue.main.async {
                        self.cartVM.addExistingItem(cartItem)
                        AudioManager.shared.play(.dropItemCart, pitchVariation: 0.03)
                        self.dragManager.currentDraggedItem = nil
                    }
                }
            case .cart:
                DispatchQueue.main.async { self.dragManager.currentDraggedItem = nil }
            default:
                break
            }
        } else {
            // from shelf
            if self.cartVM.isFull {
                self.cartVM.triggerShake()
                print("Cart full, item not added.")
                AudioManager.shared.play(.dropFail)
                
                let fall = FloatingItemFeedback(
                    id: UUID(),
                    item: groceryItem,
                    startPoint: self.dragManager.currentDragLocation,
                    originPoint: self.dragManager.dragStartLocation,
                    shouldFadeOut: true, // FADE OUT
                    trackedItemID: draggedItem.id
                )
                self.floatingItems.append(fall)
                self.dragManager.currentDraggedItem = nil
                return
            }
            
            DispatchQueue.main.async {
                self.cartVM.addNewItem(groceryItem)
                AudioManager.shared.play(.dropItemCart, pitchVariation: 0.03)
                self.dragManager.currentDraggedItem = nil
            }
        }
    }
    
    func handleGroceryDropOnRemoveZone(draggedItem: DraggedItem) {
        print("Remove from cart")
        AudioManager.shared.play(.dropItemTrash, pitchVariation: 0.03)
        
        if let source = draggedItem.source {
            switch source {
            case .cart:
                DispatchQueue.main.async {
                    self.cartVM.removeItem(withId: draggedItem.id)
                    self.dragManager.currentDraggedItem = nil
                }
            case .cashierCounter:
                DispatchQueue.main.async {
                    self.cashierVM.removeFromCounter(withId: draggedItem.id)
                    self.dragManager.currentDraggedItem = nil
                }
            default:
                break
            }
        }
    }
    
    func handleGroceryDropOnShelf(draggedItem: DraggedItem) {
        if draggedItem.source == .cart {
            AudioManager.shared.play(.dropItemTrash, pitchVariation: 0.03)
            DispatchQueue.main.async {
                self.cartVM.removeItem(withId: draggedItem.id)
                self.dragManager.currentDraggedItem = nil
            }
        } else {
            DispatchQueue.main.async { self.dragManager.currentDraggedItem = nil }
        }
    }
    
    func handleGroceryDropOnCreateDish(groceryItem: Item, draggedItem: DraggedItem) {
        if draggedItem.source == .createDishOverlay {
            DispatchQueue.main.async {
                self.dishVM.createDishItem.append(CartItem(item: groceryItem))
                if let index = self.cashierVM.purchasedItems.firstIndex(where: { $0.item.id == draggedItem.id }) {
                    self.cashierVM.purchasedItems.remove(at: index)
                }
            }
            dragManager.currentDraggedItem = nil
        }
    }
    
    func handleGroceryDropOnCreateDishOverlay(groceryItem: Item, draggedItem: DraggedItem) {
        if draggedItem.source == .createDish {
            DispatchQueue.main.async {
                withAnimation {
                    self.cashierVM.purchasedItems.append(CartItem(item: groceryItem))
                    if let index = self.dishVM.createDishItem.firstIndex(where: { $0.id == draggedItem.id }) {
                        self.dishVM.createDishItem.remove(at: index)
                    }
                }
            }
            dragManager.currentDraggedItem = nil
        }
    }
    
    func handleOnPaymentCounter() {
        //        print("Dropped money (\(price)) on payment counter")
        //        self.walletVM.removeItem(withId: draggedItem.id)
        //        let droppedMoney = Money(price: price)
        //        self.cashierVM.acceptMoney(droppedMoney)
        let requiredAmount = self.cashierVM.totalPrice
        
        // Guard checks
        guard requiredAmount > 0 else {
            DispatchQueue.main.async { self.dragManager.currentDraggedItem = nil }
            return
        }
        
        // KONDISI 2: Duitnya yang di kasih ga cukup
        guard self.cashierVM.totalReceivedMoney >= requiredAmount else {
            return
        }
        
        // Success logic
        AudioManager.shared.play(.paymentSuccess, pitchVariation: 0.02)
        
        // Itung kembalian kalau ada
        // MARK: Case unit nya 1 (old version)
        //        let changeAmount = self.cashierVM.totalReceivedMoney - requiredAmount
        //
        //        if changeAmount != 0 {
        //            self.walletVM.addMoney(Currency.breakdown(from: changeAmount))
        //        }
        
        // Case unit udh pecahan
        // MARK: Case unit nya pecahan (new version)
        var remaining = requiredAmount
        var usedMoney: [Money] = []
        var unusedMoney: [Money] = []
        var leftoverFromLastUsedBill = 0
        
        // Sort received money from smallest to largest (we try to use smaller bills first)
        let sortedReceived = self.cashierVM.receivedMoney.sorted { $0.currency.value < $1.currency.value }
        
        for money in sortedReceived {
            if remaining > 0 {
                let prevRemaining = remaining
                remaining -= money.currency.value
                usedMoney.append(money)
                
                // If this bill made us cover (or overpay), compute leftover from this bill only
                if remaining <= 0 {
                    // prevRemaining was > 0 (we entered because remaining > 0)
                    // leftover = portion of this bill that is not needed:
                    leftoverFromLastUsedBill = money.currency.value - prevRemaining
                    // don't break here — we'll treat the rest of loop as unused once remaining <= 0
                }
            } else {
                // money not used at all — return intact
                unusedMoney.append(money)
            }
        }
        
        // Return unused (not used) bills intact
        if !unusedMoney.isEmpty {
            DispatchQueue.main.async {
                self.walletVM.moneys.append(contentsOf: unusedMoney)
            }
        }
        
        // If there is leftover from the last used bill, break it down and add to wallet
        if leftoverFromLastUsedBill > 0 {
            let changeCurrencies = Currency.breakdown(from: leftoverFromLastUsedBill)
            if !changeCurrencies.isEmpty {
                DispatchQueue.main.async {
                    self.walletVM.addMoney(changeCurrencies) // uses existing addMoney([Currency])
                }
            }
        }
        
        DispatchQueue.main.async {
            self.cashierVM.receivedMoney.removeAll()
            self.cashierVM.checkOutSuccess()
        }
    }
    
    func handleMoneyDropOnWallet(currency: Currency, draggedItem: DraggedItem) {
        print("Dropped money (\(currency.value)) back on wallet")
    }
    
    func handleCashierOnLoadingCounter(groceryItem: Item, draggedItem: DraggedItem) {
        guard let source = draggedItem.source, source == .cart else {
            DispatchQueue.main.async { self.dragManager.currentDraggedItem = nil }
            return
        }
        
        // If counter is not full
        if !self.cashierVM.isLimitCounterReached() {
            AudioManager.shared.play(.scanItem, pitchVariation: 0.02)
            if let cartItem = self.cartVM.popItem(withId: draggedItem.id) {
                DispatchQueue.main.async {
                    self.cashierVM.addToCounter(cartItem)
                    self.dragManager.currentDraggedItem = nil
                }
            }
            return
        } else {
            AudioManager.shared.play(.dropFail)
            
            let fall = FloatingItemFeedback(
                id: UUID(),
                item: groceryItem,
                startPoint: self.dragManager.currentDragLocation,
                originPoint: self.dragManager.dragStartLocation,
                shouldFadeOut: false, // NO FADE
                trackedItemID: draggedItem.id
            )
            self.floatingItems.append(fall)
            self.itemsCurrentlyAnimating.append(draggedItem.id) // Hide original item
            self.dragManager.currentDraggedItem = nil
        }
    }
}

private extension PlayViewModel {
    func generateBudget(min: Int, max: Int, step: Int) -> Int {
        let range = stride(from: min, through: max, by: step)
            .map { $0 }
            .filter { $0 != 50 }
        
        return range.randomElement() ?? min
    }
}
