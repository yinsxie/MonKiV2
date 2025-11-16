//
//  CartItem.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 14/11/25.
//

import Foundation

struct CartItem: Identifiable, Equatable {
    let id: UUID = UUID()
    
    let item: Item
    
    static func == (lhs: CartItem, rhs: CartItem) -> Bool {
        lhs.id == rhs.id
    }
}
