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
    }
}

// MARK: Drop Handlers
private extension PlayViewModel {
    func handleGroceryDrop(zone: DropZoneType, groceryItem: Item, draggedItem: DraggedItem) {
        switch zone {
        case .cart:
            withAnimation(.spring) {
                handleGroceryDropOnCart(groceryItem: groceryItem, draggedItem: draggedItem)
            }
        case .cashierLoadingCounter:
            // No animation here
            handleCashierOnLoadingCounter(groceryItem: groceryItem, draggedItem: draggedItem)
        case .cashierRemoveItem:
            withAnimation(.spring) {
                handleGroceryDropOnRemoveZone(draggedItem: draggedItem)
            }
        default:
            break
        }
    }
    
    func handleMoneyDrop(zone: DropZoneType, price: Int, draggedItem: DraggedItem) {
//        withAnimation(.spring) {
            switch zone {
            case .cashierPaymentCounter:
                handleMoneyDropOnPaymentCounter(price: price, draggedItem: draggedItem)
            case .wallet:
                handleMoneyDropOnWallet(price: price, draggedItem: draggedItem)
            default:
                print("Dropped money on an invalid zone (\(zone.rawValue))")
            }
//        }
    }
    
    func handleGroceryDropOnCart(groceryItem: Item, draggedItem: DraggedItem) {
        print("test")
        
        if let source = draggedItem.source {
            switch source {
            case .cashierCounter:
                // from counter
                if self.cartVM.isFull {
                    DispatchQueue.main.async {
                        print("Cart full, item not moved.")
                        AudioManager.shared.play(.dropFail)
                    }
                    return
                }
                if let cartItem = self.cashierVM.popFromCounter(withId: draggedItem.id) {
                    DispatchQueue.main.async {
                        self.cartVM.addExistingItem(cartItem)
                        AudioManager.shared.play(.dropItemCart, pitchVariation: 0.03)
                    }
                }
            case .cart:
                // from cart itself
                break
            }
        } else {
            // from shelf
            if self.cartVM.isFull {
                DispatchQueue.main.async {
                    print("Cart full, item not added.")
                    AudioManager.shared.play(.dropFail)
                }
                return
            }

            DispatchQueue.main.async {
                self.cartVM.addNewItem(groceryItem)
                AudioManager.shared.play(.dropItemCart, pitchVariation: 0.03)
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
                }
            case .cashierCounter:
                DispatchQueue.main.async {
                    self.cashierVM.removeFromCounter(withId: draggedItem.id)
                }
            }
        }
    }
    
    func handleMoneyDropOnPaymentCounter(price: Int, draggedItem: DraggedItem) {
        //        print("Dropped money (\(price)) on payment counter")
        //        self.walletVM.removeItem(withId: draggedItem.id)
        //        let droppedMoney = Money(price: price)
        //        self.cashierVM.acceptMoney(droppedMoney)
        let requiredAmount = self.cashierVM.totalPrice
        let draggedAmount = price
        
        // KONDISI 1: Gaada barang yg harus dibayar
        guard requiredAmount > 0 else {
            return
        }
        
        // KONDISI 2: Duitnya ga cukup
        guard draggedAmount >= requiredAmount else {
            return
        }
        
        // KONDISI 3: Duitnya Cukup (Lunas atau Ada Kembalian)
        AudioManager.shared.play(.paymentSuccess, pitchVariation: 0.02)
        self.walletVM.removeItem(withId: draggedItem.id)
        let droppedMoney = Money(price: draggedAmount)
        self.cashierVM.acceptMoney(droppedMoney)
        
        // Itung kembalian kalau ada
        let changeAmount = draggedAmount - requiredAmount
        currentBudget = changeAmount
        
        if changeAmount >= 0 {
            // Case ada kembalian
            print("Giving change: \(changeAmount)")
            let changeMoney = Money(price: changeAmount)
            
            // kasih kembalian
            DispatchQueue.main.async {
                withAnimation {
                    self.walletVM.addMoney(changeMoney)
                }
            }
        }
        
        self.cashierVM.checkOutSuccess()
    }
    
    func handleMoneyDropOnWallet(price: Int, draggedItem: DraggedItem) {
        print("Dropped money (\(price)) back on wallet")
    }
    
    func handleCashierOnLoadingCounter(groceryItem: Item, draggedItem: DraggedItem) {
        
        guard let source = draggedItem.source, source == .cart else { return }
      
        // If counter is full
        if !self.cashierVM.isLimitCounterReached() {
            AudioManager.shared.play(.scanItem, pitchVariation: 0.02)
            if let cartItem = self.cartVM.popItem(withId: draggedItem.id) {
                DispatchQueue.main.async {
                    self.cashierVM.addToCounter(cartItem)
                }
            }
            return
        }
        
        AudioManager.shared.play(.dropFail)
    }
}

private extension PlayViewModel {
    func generateBudget(min: Int, max: Int, step: Int) -> Int {
        let range = stride(from: min, through: max, by: step).map { $0 }
        return range.randomElement() ?? min
    }
}
