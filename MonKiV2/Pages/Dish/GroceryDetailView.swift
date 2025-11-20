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
    let offset: CGFloat = 20
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
            Image(grocery.item.imageAssetPath)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: size, maxHeight: size)
            
            Text("\(grocery.quantity)")
                .opacity(grocery.quantity > 1 ? 1 : 0)
                .font(.wendyOne(size: 45))
                .offset(x: offset, y: offset)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    GroceryDetailView(grocery: GroceryItem(id: UUID(), item: Item.mockItem, quantity: 1))
}
