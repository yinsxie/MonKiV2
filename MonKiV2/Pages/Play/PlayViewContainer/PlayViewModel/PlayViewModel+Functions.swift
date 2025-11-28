//
//  PlayViewModel+Functions.swift
//  MonKiV2
//
//  Created by William on 24/11/25.
//

import SwiftUI

extension PlayViewModel {
    func setupGameLogic() {
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
            
            switch draggedItem.payload {
            case .grocery(let groceryItem):
                self.handleGroceryDropFailed(groceryItem: groceryItem, draggedItem: draggedItem)
            case .money(let currency):
                self.handleMoneyDropFailed(currency: currency, draggedItem: draggedItem)
            }
        }
    }
    
    func startTour() {
        withAnimation {
            isIntroButtonVisible = false
        }
        
        withAnimation(.easeInOut(duration: 2.5)) {
            setCurrentIndex(to: .ATM)
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
            
            self.walletVM.addMoney(breakdown)
        }
    }
}
