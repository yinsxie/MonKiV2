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
    var dragManager = DragManager()
    
    init() {
        // On Game Start
        let budget = generateBudget(min: 20, max: 100, step: 10)
        self.initialBudget = budget
        self.currentBudget = budget
        
        self.shelfVM = ShelfViewModel(parent: self)
        self.cartVM = CartViewModel(parent: self)
        self.cashierVM = CashierViewModel(parent: self)
        
        setupGameLogic()
    }
    
    private func setupGameLogic() {
        dragManager.onDropSuccess = { [weak self] zone, draggedItem in
            guard let self = self else { return }
            
            switch draggedItem.payload {
                
            case .grocery(let groceryItem):
                withAnimation(.spring) {
                    switch zone {
                    case .cart:
                        if !self.cartVM.containsItem(withId: draggedItem.id) {
                            DispatchQueue.main.async {
                                self.cartVM.addItem(groceryItem)
                                //Check if source from counter, if yes, remove counter data
                                if let source = draggedItem.source, source == .cashierCounter {
                                    self.cashierVM.removeFromCounter(withId: draggedItem.id)
                                }
    //                            self.shelfVM.removeItem(withId: groceryItem.id)
                            }
                        }
                    case .cashierLoadingCounter:
                        print("Moved to cashier")
                        if let source = draggedItem.source, source == .cart {
                            DispatchQueue.main.async {
                                self.cartVM.removeItem(withId: draggedItem.id)
                                self.cashierVM.addToCounter(CartItem(item: groceryItem))
                            }
                        }
                    case .cashierRemoveItem:
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
                        
                    default: break
                    }
                }
            }
        }
    }
}

extension PlayViewModel {
    
}

private extension PlayViewModel {
    func generateBudget(min: Int, max: Int, step: Int) -> Int {
        let range = stride(from: min, through: max, by: step).map { $0 }
        return range.randomElement() ?? min
    }
}
