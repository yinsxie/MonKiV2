//
//  ShoppingBagView.swift
//  MonKiV2
//
//  Created by William on 16/11/25.
//

import SwiftUI

struct ShoppingBagView: View {
    let items: [CartItem]
    
    private let itemsPerRow = 3
    
    private var itemRows: [[CartItem]] {
        return items.chunked(into: itemsPerRow)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: -50) {
                Spacer()
                
                ForEach(Array(itemRows.enumerated().reversed()), id: \.offset) { index, rowItems in
                    HStack(spacing: -50) {
                        ForEach(rowItems) { cartItem in
                            GroceryItemView(item: cartItem.item)
//                            Image(cartItem.item.imageAssetPath)
                                .scaleEffect(0.85)
                                .shadow(radius: 2)
                                .transition(.scale.combined(with: .opacity))
                                .rotationEffect(.degrees(Double.random(in: -10...10)))
                                .zIndex(Double(rowItems.count) - Double(rowItems.firstIndex(of: cartItem) ?? 0))
                        }
                    }
                    .environment(\.layoutDirection, .rightToLeft)
                    .frame(width: 231, alignment: .leading)
                    .zIndex(Double(itemRows.count) - Double(index))
                }
            }
//            .padding(.bottom, 35)
            .frame(width: 251, height: 240)
            .allowsHitTesting(false)
            
            Image("plasticBag")
                .resizable()
                .scaledToFit()
                .frame(width: 251)
        }
    }
}
