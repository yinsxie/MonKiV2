//
//  DragOverlayView.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//

import SwiftUI

struct DragOverlayView: View {
    @Environment(DragManager.self) var manager
    
    var body: some View {
        if let item = manager.currentDraggedItem {
            Group {
                switch item.payload {
                case .grocery(let groceryItem):
                    GroceryItemView(item: groceryItem)
                case .money(let price):
                    MoneyView(money: Money(price: price))
                }
            }
            .position(manager.currentDragLocation)
            .allowsHitTesting(false) // very importanto line of code
        }
    }
}
