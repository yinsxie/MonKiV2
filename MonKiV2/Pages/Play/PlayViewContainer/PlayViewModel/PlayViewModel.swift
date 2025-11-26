//
//  PlayViewModel.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//

import SwiftUI

@MainActor
@Observable class PlayViewModel {
    
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
    var budgetSharingVM: BudgetSharingViewModel!
    
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
    
    var isBudgetSharingActive: Bool = false
    
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
        
        if gameMode == .multiplayer {
            self.isBudgetSharingActive = true
            self.budgetSharingVM = BudgetSharingViewModel(parent: self)
        }
        
        setupGameLogic()
        // MARK: - ini komen dulu supaya duitnya ga langsung masuk dompet
        //                        let currencyBreakdown = Currency.breakdown(from: budget)
        //                        walletVM.addMoney(currencyBreakdown)
        
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
