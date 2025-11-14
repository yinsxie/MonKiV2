//
//  PlayViewModel.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//

import SwiftUI

// this is basically God class PlayViewModel
@Observable class PlayEngine {
    var shelfVM = ShelfViewModel()
    var cartVM = CartViewModel()
    var cashierVM = CashierViewModel()
    var walletVM = WalletViewModel()
    var dragManager = DragManager()
    var currentPageIndex: Int? = 0
    
    init() {
        setupGameLogic()
        setupInitialWallet()
    }
    
    // MARK: - Dummy setup money budget
    private func setupInitialWallet() {
        walletVM.addMoney(Money(price: 100))
        walletVM.addMoney(Money(price: 50))
        walletVM.addMoney(Money(price: 20))
        walletVM.addMoney(Money(price: 20))
        walletVM.addMoney(Money(price: 10))
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
                                //                            self.shelfVM.removeItem(withId: groceryItem.id)
                            }
                        }
                    case .cashierLoadingCounter:
                        print("Moved to cashier")
                    default: break
                    }
                }
                
            case .money(let price):
                withAnimation(.spring) {
                    switch zone {
                    case .cashierPaymentCounter:
                        print("Dropped money (\(price)) on payment counter")
                        self.walletVM.removeItem(withId: draggedItem.id)
                        let droppedMoney = Money(price: price)
                        self.cashierVM.acceptMoney(droppedMoney)
                        
                    case .wallet:
                        print("Dropped money (\(price)) back on wallet")
                        
                    default:
                        print("Dropped money on an invalid zone (\(zone.rawValue))")
                    }
                }
            }
        }
    }
}
