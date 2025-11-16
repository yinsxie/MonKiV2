//
//  PlayViewModel.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//

import SwiftUI

// this is basically God class PlayViewModel
@Observable class PlayViewModel {
    
    // Global Published Var for global state
    var initialBudget: Int = 0
    var currentBudget: Int = 0
    
    // VM's
    var shelfVM: ShelfViewModel!
    var cartVM: CartViewModel!
    var cashierVM: CashierViewModel!
    var walletVM: WalletViewModel!
    
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
    }
}

// MARK: Drop Handlers
private extension PlayViewModel {
    func handleGroceryDrop(zone: DropZoneType, groceryItem: Item, draggedItem: DraggedItem) {
        withAnimation(.spring) {
            switch zone {
            case .cart:
                handleGroceryDropOnCart(groceryItem: groceryItem, draggedItem: draggedItem)
            case .cashierLoadingCounter:
                handleCashierOnLoadingCounter(groceryItem: groceryItem, draggedItem: draggedItem)
            case .cashierRemoveItem:
                handleGroceryDropOnRemoveZone(draggedItem: draggedItem)
            default:
                break
            }
        }
    }
    
    func handleMoneyDrop(zone: DropZoneType, price: Int, draggedItem: DraggedItem) {
        withAnimation(.spring) {
            switch zone {
            case .cashierPaymentCounter:
                handleMoneyDropOnPaymentCounter(price: price, draggedItem: draggedItem)
            case .wallet:
                handleMoneyDropOnWallet(price: price, draggedItem: draggedItem)
            default:
                print("Dropped money on an invalid zone (\(zone.rawValue))")
            }
        }
    }
    
    func handleGroceryDropOnCart(groceryItem: Item, draggedItem: DraggedItem) {
        print("test")
        if let source = draggedItem.source {
            switch source {
            case .cashierCounter:
                // from counter
                if let cartItem = self.cashierVM.popFromCounter(withId: draggedItem.id) {
                    DispatchQueue.main.async {
                        self.cartVM.addExistingItem(cartItem)
                    }
                }
            case .cart:
                // from cart itself
                break
            }
        } else {
            // from shelf
            DispatchQueue.main.async {
                self.cartVM.addNewItem(groceryItem)
            }
        }
    }
    
    func handleGroceryDropOnRemoveZone(draggedItem: DraggedItem) {
        print("Remove from cart")
        if let source = draggedItem.source {
            switch source {
            case .cart:
                DispatchQueue.main.async {
                    self.cartVM.removeItem(withId: draggedItem.id)
                }
            case .cashierCounter:
                DispatchQueue.main.async {
                    self.cashierVM.removeFromCounter(withId: draggedItem.id)
                }
            }
        }
    }
    
    func handleMoneyDropOnPaymentCounter(price: Int, draggedItem: DraggedItem) {
        print("Dropped money (\(price)) on payment counter")
        self.walletVM.removeItem(withId: draggedItem.id)
        let droppedMoney = Money(price: price)
        self.cashierVM.acceptMoney(droppedMoney)
    }
    
    func handleMoneyDropOnWallet(price: Int, draggedItem: DraggedItem) {
        print("Dropped money (\(price)) back on wallet")
    }
    
    func handleCashierOnLoadingCounter(groceryItem: Item, draggedItem: DraggedItem) {
        guard let source = draggedItem.source, source == .cart else { return }
        
        DispatchQueue.main.async {
            // If counter is full
            if self.cashierVM.isLimitCounterReached() {
                
                // 1. Take the first item in the counter
                if let firstItemInCounter = self.cashierVM.checkOutItems.first {
                    
                    // 2. Remove dragged item from cart
                    if let itemToMoveToCounter = self.cartVM.popItem(withId: draggedItem.id) {
                        
                        // 3. Remove the first item from counter, bring it back to cart
                        if let removedFromCounter = self.cashierVM.popFromCounter(withId: firstItemInCounter.id) {
                            self.cartVM.addExistingItem(removedFromCounter)
                        }
                        
                        // 4. Add dragged item to counter
                        self.cashierVM.addToCounter(itemToMoveToCounter)
                    }
                }
                
            } else {
                // Counter still has room
                if let cartItem = self.cartVM.popItem(withId: draggedItem.id) {
                    self.cashierVM.addToCounter(cartItem)
                }
            }
        }
    }
}

private extension PlayViewModel {
    func generateBudget(min: Int, max: Int, step: Int) -> Int {
        let range = stride(from: min, through: max, by: step).map { $0 }
        return range.randomElement() ?? min
    }
}
