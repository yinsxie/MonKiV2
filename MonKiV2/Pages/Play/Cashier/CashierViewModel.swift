//
//  CashierViewModel.swift
//  MonKiV2
//
//  Created by William on 14/11/25.
//

import SwiftUI

@Observable
final class CashierViewModel {
    
    var receivedMoney: [Money] = []
    
    func acceptMoney(_ money: Money) {
        receivedMoney.append(money)
        print("Cashier received money: \(money.price)")
    }
    
    var totalReceivedMoney: Int {
        receivedMoney.reduce(0) { $0 + $1.price }
    }
    
}
