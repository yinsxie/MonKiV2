//
//  CurrencyBreakdownFactory.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 14/11/25.
//

import Foundation

struct BreakdownResult {
    let source: Currency
    let targets: [Currency]
}

struct CurrencyBreakdownFactory {
    
    static func getRandomBreakdown() -> BreakdownResult {
        let breakableCurrencies = Currency.allCases.filter { $0.value > 1 }
        
        guard let randomCurrency = breakableCurrencies.randomElement() else {
            return BreakdownResult(source: .idr2, targets: [.idr1, .idr1])
        }
        
        return BreakdownResult(
            source: randomCurrency,
            targets: getNextSmallestBreakdown(for: randomCurrency)
        )
    }
    
    private static func getNextSmallestBreakdown(for currency: Currency) -> [Currency] {
        switch currency {
        case .idr100: return [.idr50, .idr50]
        case .idr50:  return [.idr20, .idr20, .idr10]
        case .idr20:  return [.idr10, .idr10]
        case .idr10:  return [.idr5, .idr5]
        case .idr5:   return [.idr2, .idr2, .idr1]
        case .idr2:   return [.idr1, .idr1]
        case .idr1:   return []
        }
    }
}
