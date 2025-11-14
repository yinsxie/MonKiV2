//
//  WalletViewModel.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 14/11/25.
//

import SwiftUI

@Observable class WalletViewModel {
    var moneys: [Money] = []

    func addMoney(_ money: Money) {
        let newMoney = Money(price: money.price)
        moneys.append(newMoney)
        print("Money added to wallet: \(money.price) (Instance ID: \(newMoney.id))")
    }
    
    func removeItem(withId id: UUID) {
        moneys.removeAll{ $0.id == id }
        print("Item removed from cart with instance id: \(id)")
    }
    
    func removeFirstMoney(withPrice price: Int) {
        guard let index = moneys.firstIndex(where: { $0.price == price }) else {
            return
        }
        moneys.remove(at: index)
    }
    
    var totalMoney: Int {
        moneys.reduce(0) { $0 + $1.price }
    }
}
