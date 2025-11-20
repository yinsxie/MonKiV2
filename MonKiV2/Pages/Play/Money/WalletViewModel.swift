//
//  WalletViewModel.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 14/11/25.
//

import SwiftUI

@Observable class WalletViewModel {
    weak var parent: PlayViewModel?
    
    init(parent: PlayViewModel?) {
        self.parent = parent
    }
    
    var moneys: [Money] = []
    var isWalletOpen: Bool = false
    
    var walletSorted: [MoneyGroup] {
        wallet.sorted { $0.money.currency.value > $1.money.currency.value }
    }
    
    func addMoney(_ currency: Currency) {
        let newMoney = Money(forCurrency: currency)
        moneys.append(newMoney)
        print("Money added to wallet: \(currency.value) (Instance ID: \(newMoney.id))")
    }
    
    func addMoney(_ currencies: [Currency]) {
        print("Adding multiple currencies to wallet...")
        for currency in currencies {
            let newMoney = Money(forCurrency: currency)
            moneys.append(newMoney)
            print("Money added to wallet: \(currency.value) (Instance ID: \(newMoney.id))")
        }
    }
    
    func removeItem(withId id: UUID) {
        moneys.removeAll{ $0.id == id }
        print("Item removed from cart with instance id: \(id)")
    }
    
    func removeFirstMoney(withCurrency currency: Currency) {
        guard let index = moneys.firstIndex(where: { $0.currency == currency }) else {
            return
        }
        moneys.remove(at: index)
    }
}

struct MoneyGroup: Identifiable {
    let id = UUID()
    let money: Money      // representative
    let count: Int
}

extension WalletViewModel {
    var wallet: [MoneyGroup] {
        var temp: [Currency: (money: Money, count: Int)] = [:]
        
        for money in moneys {
            if let existing = temp[money.currency] {
                temp[money.currency] = (existing.money, existing.count + 1)
            } else {
                temp[money.currency] = (money, 1)
            }
        }
        
        return temp.values.map { MoneyGroup(money: $0.money, count: $0.count) }
    }
}
