//
//  PlayViewModel.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//

import SwiftUI

@MainActor
@Observable class PlayViewModel: MatchManagerDelegate {
    
    var gameMode: GameMode
    var matchManager: MatchManager?
    
    var gamePages: [PageIdentifier]
    
    var floatingItems: [FloatingItemFeedback] = [] // track items that need animating floating item feedback
    var itemsCurrentlyAnimating: [UUID] = [] // tracks items that are animating but MUST become visible again (no fade)
    
    // Global Published Var for global state
    var initialBudget: Int = 0
    var currentBudget: Int {
        walletVM.moneys.reduce(0) { $0 + $1.currency.value }
    }
    
    // VM's
    var shelfVM: ShelfViewModel!
    var cartVM: CartViewModel!
    var cashierVM: CashierViewModel!
    var walletVM: WalletViewModel!
    var dishVM: CreateDishViewModel!
    var atmVM: ATMViewModel!
    
    // View State
    var isScrollDisabled: Bool {
        dragManager.isDragging
                        || atmVM.isZoomed
                        || cashierVM.isReturnedMoneyPrompted
                        || cashierVM.isPlayerStopScrollingWhileReceivedMoney
    }
    
    // Start at CreateDishView
    var currentPageIndex: Int? = 0
    var isIntroButtonVisible: Bool = true
    
    var dragManager = DragManager()
    
    var atmFrame: CGRect = .zero
    var walletFrame: CGRect = .zero
    
    var isFlyingMoney: Bool = false
    var flyingMoneyCurrency: Currency?
    
    init(gameMode: GameMode, matchManager: MatchManager? = nil) {
        self.gameMode = gameMode
        self.gamePages = PlayViewModel.getPage(for: gameMode)
        self.matchManager = matchManager
        
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
        //                        let currencyBreakdown = Currency.breakdown(from: budget)
        //                        walletVM.addMoney(currencyBreakdown)
        
    }
    
    func connectToMatch() {
        print("🔗 PlayViewModel connecting to MatchManager delegate")
        self.matchManager?.delegate = self
    }
    
    func didRemotePlayerPurchase(itemName: String) {
            // Opponent bought something. Add it to MY purchased items.
            print("📡 Opponent bought: \(itemName)")
            if let item = findItemByName(itemName) {
                // Add directly to purchased items (skip animation/payment for sync simplicity)
                cashierVM.purchasedItems.append(CartItem(item: item))
            }
        }
        
        func didRemotePlayerAddToDish(itemName: String) {
            // Opponent moved item to Dish.
            // 1. Find it in purchased items
            if let index = cashierVM.purchasedItems.firstIndex(where: { $0.item.name == itemName }) {
                let cartItem = cashierVM.purchasedItems[index]
                
                // 2. Move to Dish
                dishVM.createDishItem.append(cartItem)
                cashierVM.purchasedItems.remove(at: index)
                print("📡 Opponent added \(itemName) to dish")
            } else {
                // Fail-safe: If desync happened, force create it
                if let item = findItemByName(itemName) {
                    dishVM.createDishItem.append(CartItem(item: item))
                }
            }
        }
        
        func didRemotePlayerRemoveFromDish(itemName: String) {
            // Opponent put item back in bag
            if let index = dishVM.createDishItem.firstIndex(where: { $0.item.name == itemName }) {
                let cartItem = dishVM.createDishItem[index]
                
                cashierVM.purchasedItems.append(cartItem)
                dishVM.createDishItem.remove(at: index)
                print("📡 Opponent removed \(itemName) from dish")
            }
        }
        
        // Helper to find item object from string name
        private func findItemByName(_ name: String) -> Item? {
            // Assuming Item.items is your static catalog
            return Item.items.first(where: { $0.name == name })
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
