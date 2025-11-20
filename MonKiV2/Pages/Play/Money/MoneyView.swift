//
//  MoneyView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 14/11/25.
//

import SwiftUI

struct MoneyView: View {
    let money: Money
    var quantity: Int = 1
    var isBeingDragged: Bool = false
    var width: CGFloat = 250
    
    var body: some View {
        ZStack {
            if quantity > 1 {
                ForEach(1..<min(quantity, 3), id: \.self) { index in
                    Image(money.currency.imageAssetPath)
                        .resizable()
                        .scaledToFit()
                        .frame(minWidth: width)
                        .frame(width: width)
                        .frame(maxWidth: width)
                        .brightness(-0.3)
                        .offset(x: CGFloat(index * 8), y: CGFloat(index * 8))
                        .zIndex(-Double(index))
                }
            }
            
            Image(money.currency.imageAssetPath)
                .resizable()
                .scaledToFit()
                .frame(minWidth: width)
                .frame(width: width)
                .frame(maxWidth: width)
        }
    }
}
