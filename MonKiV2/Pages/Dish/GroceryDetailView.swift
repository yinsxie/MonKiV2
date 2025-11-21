//
//  GroceryDetailView.swift
//  MonKiV2
//
//  Created by William on 19/11/25.
//

import SwiftUI

struct GroceryDetailView: View {
    var grocery: GroceryItem
    
    let size: CGFloat = 136
    let offset: CGFloat = 30
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
            Image(grocery.item.imageAssetPath)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: size, maxHeight: size)
           
            if grocery.quantity > 1 {
                CircleNumberView(number: grocery.quantity)
                    .offset(x: offset, y: offset)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    GroceryDetailView(grocery: GroceryItem(id: UUID(), item: Item.mockItem, quantity: 2))
}
