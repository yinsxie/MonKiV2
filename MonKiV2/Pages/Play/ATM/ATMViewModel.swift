//
//  ATMViewModel.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 18/11/25.
//

import SwiftUI

struct ATMOption {
    let amount: Int
    let cooldownDuration: TimeInterval
}

@Observable class ATMViewModel {
    weak var parent: PlayViewModel?
    
    var atmBalance: Int = 0
    var isZoomed: Bool = false
    
    var showFlyingMoney: Bool = false
    var flyingMoneyValue: Int = 0
    var isProcessing: Bool = false
    
    var cooldownProgress: [Int: Double] = [50: 0.0, 20: 0.0, 10: 0.0]
    var activeCooldownProgress: Double {
        return cooldownProgress.values.max() ?? 0.0
    }
    private var timers: [Int: Timer] = [:]
    
    let options: [ATMOption] = [
        ATMOption(amount: 50, cooldownDuration: 90),
        ATMOption(amount: 20, cooldownDuration: 60),
        ATMOption(amount: 10, cooldownDuration: 30)
    ]
    
    init(parent: PlayViewModel, initialBalance: Int) {
        self.parent = parent
        self.atmBalance = initialBalance
    }
    
    func handleOpenATM() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            AudioManager.shared.play(.zoomInATM, volume: 5.0)
            isZoomed = true
        }
    }
    
    func handleCloseATM() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isZoomed = false
        }
    }
    
    func withdraw(amount: Int) {
        AudioManager.shared.play(.beepATM, volume: 5.0)
        guard let option = options.first(where: { $0.amount == amount }) else { return }
        guard atmBalance >= amount else { return }
        guard (cooldownProgress[amount] ?? 0) == 0 else { return }
        guard !isProcessing else { return }
        
        guard let parent = self.parent else {
            print("Guard: Parent PlayViewModel nil. Transaksi dibatalkan agar uang tidak hilang.")
            return
        }
        
        DispatchQueue.main.async {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                self.parent?.walletVM.isWalletOpen = true
            }
        }
        self.isProcessing = true
        self.flyingMoneyValue = amount
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            guard self.atmBalance >= amount else {
                self.isProcessing = false
                self.flyingMoneyValue = 0
                return
            }
            
            self.atmBalance -= amount
            self.startCooldown(for: option)
            
            self.isProcessing = false
            self.flyingMoneyValue = 0
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                self.isZoomed = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                print("Kasih sinyal animasi uang \(amount) ke PlayVM")
                parent.triggerMoneyFlyAnimation(amount: amount)
            }
        }
    }
    
    private func startCooldown(for option: ATMOption) {
        cooldownProgress[option.amount] = 1.0
        
        let step: TimeInterval = 0.1
        let totalSteps = option.cooldownDuration / step
        let decrement = 1.0 / totalSteps
        
        timers[option.amount]?.invalidate()
        
        timers[option.amount] = Timer.scheduledTimer(withTimeInterval: step, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            if var currentProgress = self.cooldownProgress[option.amount] {
                currentProgress -= decrement
                
                if currentProgress <= 0 {
                    self.cooldownProgress[option.amount] = 0.0
                    timer.invalidate()
                } else {
                    self.cooldownProgress[option.amount] = currentProgress
                }
            }
        }
    }
    
    func isButtonDisabled(amount: Int) -> Bool {
        if atmBalance < amount { return true }
        if (cooldownProgress[amount] ?? 0) > 0 { return true }
        return false
    }
    
    func handleCloseAndScrollToShelf() {
        handleCloseATM()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            withAnimation(.easeInOut(duration: 0.5)) {
                self?.parent?.currentPageIndex = 1
            }
        }
    }
}
