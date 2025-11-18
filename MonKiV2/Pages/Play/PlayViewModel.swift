//
//  PlayViewModel.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//

import SwiftUI

@Observable class PlayViewModel {
    var floatingItems: [FloatingItemFeedback] = []
    
    // Global Published Var for global state
    var initialBudget: Int = 0
    var currentBudget: Int = 0
    
    // VM's
    var shelfVM: ShelfViewModel!
    var cartVM: CartViewModel!
    var cashierVM: CashierViewModel!
    var walletVM: WalletViewModel!
    var dishVM: CreateDishViewModel!
    
    var currentPageIndex: Int? = 0
    
    var dragManager = DragManager()
    
    init() {
        // On Game Start
        let budget = generateBudget(min: 20, max: 100, step: 10)
        self.initialBudget = budget
        self.currentBudget = budget
        
        self.shelfVM = ShelfViewModel(parent: self)
        self.cartVM = CartViewModel(parent: self)
        self.cashierVM = CashierViewModel(parent: self)
        self.walletVM = WalletViewModel(parent: self)
        self.dishVM = CreateDishViewModel(parent: self)
        
        setupGameLogic()
        walletVM.addMoney(Money(price: budget))
    }
    
    private func setupGameLogic() {
        dragManager.onDropSuccess = { [weak self] zone, draggedItem in
            guard let self = self else { return }
            
            switch draggedItem.payload {
            case .grocery(let groceryItem):
                self.handleGroceryDrop(zone: zone, groceryItem: groceryItem, draggedItem: draggedItem)
            case .money(let price):
                print("Dropped money with price: \(price)")
                self.handleMoneyDrop(zone: zone, price: price, draggedItem: draggedItem)
            }
        }
        
        dragManager.onDropFailed = { [weak self] draggedItem in
            guard let self = self else { return }
            self.handleDropFailed(draggedItem: draggedItem)
        }
    }
    
    func removeFallingItem(id: UUID) {
        floatingItems.removeAll(where: { $0.id == id })
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
        default:
            DispatchQueue.main.async { self.dragManager.currentDraggedItem = nil }
        }
    }
    
    func handleMoneyDrop(zone: DropZoneType, price: Int, draggedItem: DraggedItem) {
        switch zone {
        case .cashierPaymentCounter:
            handleMoneyDropOnPaymentCounter(price: price, draggedItem: draggedItem)
        case .wallet:
            handleMoneyDropOnWallet(price: price, draggedItem: draggedItem)
        default:
            print("Dropped money on an invalid zone (\(zone.rawValue))")
            DispatchQueue.main.async { self.dragManager.currentDraggedItem = nil }
        }
    }
    
    func handleGroceryDropOnCart(groceryItem: Item, draggedItem: DraggedItem) {
        print("test")
        
        if let source = draggedItem.source {
            switch source {
            case .cashierCounter:
                // from counter
                if self.cartVM.isFull {
                    self.cartVM.triggerShake()
                    print("Cart full, item not moved.")
                    AudioManager.shared.play(.dropFail)
                    
                    let fall = FloatingItemFeedback(
                        item: groceryItem,
                        startPoint: self.dragManager.currentDragLocation,
                        originPoint: self.dragManager.dragStartLocation
                    )
                    self.floatingItems.append(fall)
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
            }
        } else {
            // from shelf
            if self.cartVM.isFull {
                self.cartVM.triggerShake()
                print("Cart full, item not added.")
                AudioManager.shared.play(.dropFail)
                
                let fall = FloatingItemFeedback(
                    item: groceryItem,
                    startPoint: self.dragManager.currentDragLocation,
                    originPoint: self.dragManager.dragStartLocation
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
    
    func handleMoneyDropOnPaymentCounter(price: Int, draggedItem: DraggedItem) {
        let requiredAmount = self.cashierVM.totalPrice
        let draggedAmount = price
        
        // Guard checks
        guard requiredAmount > 0 else {
            DispatchQueue.main.async { self.dragManager.currentDraggedItem = nil }
            return
        }
        guard draggedAmount >= requiredAmount else {
            DispatchQueue.main.async { self.dragManager.currentDraggedItem = nil }
            return
        }
        
        // Success logic
        AudioManager.shared.play(.paymentSuccess, pitchVariation: 0.02)
        self.walletVM.removeItem(withId: draggedItem.id)
        let droppedMoney = Money(price: draggedAmount)
        self.cashierVM.acceptMoney(droppedMoney)
        
        let changeAmount = draggedAmount - requiredAmount
        currentBudget = changeAmount
        
        if changeAmount >= 0 {
            print("Giving change: \(changeAmount)")
            let changeMoney = Money(price: changeAmount)
            
            DispatchQueue.main.async {
                withAnimation {
                    self.walletVM.addMoney(changeMoney)
                }
            }
        }
        
        self.cashierVM.checkOutSuccess()
        
        DispatchQueue.main.async {
            self.dragManager.currentDraggedItem = nil
        }
    }
    
    func handleMoneyDropOnWallet(price: Int, draggedItem: DraggedItem) {
        print("Dropped money (\(price)) back on wallet")
        DispatchQueue.main.async { self.dragManager.currentDraggedItem = nil }
    }
    
    func handleCashierOnLoadingCounter(groceryItem: Item, draggedItem: DraggedItem) {
        guard let source = draggedItem.source, source == .cart else {
            DispatchQueue.main.async { self.dragManager.currentDraggedItem = nil }
            return
        }
        
        if !self.cashierVM.isLimitCounterReached() {
            AudioManager.shared.play(.scanItem, pitchVariation: 0.02)
            if let cartItem = self.cartVM.popItem(withId: draggedItem.id) {
                DispatchQueue.main.async {
                    self.cashierVM.addToCounter(cartItem)
                    self.dragManager.currentDraggedItem = nil
                }
            }
            return
        }
        
        AudioManager.shared.play(.dropFail)
        DispatchQueue.main.async { self.dragManager.currentDraggedItem = nil }
    }
}

private extension PlayViewModel {
    func generateBudget(min: Int, max: Int, step: Int) -> Int {
        let range = stride(from: min, through: max, by: step).map { $0 }
        return range.randomElement() ?? min
    }
}
