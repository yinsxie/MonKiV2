//
//  ShoppingBagView.swift
//  MonKiV2
//
//  Created by William on 16/11/25.
//

import SwiftUI

struct ShoppingBagView: View {
    @Environment(CashierViewModel.self) var viewModel
    
    var body: some View {
        ZStack {
            Image("shopping_bag")
                .resizable()
                .scaledToFit()
                .frame(width: 251)
            
            ZStack {
                // 1st item (middle)
                if let item = viewModel.purchasedItemVisualized[safe: 0] {
                    Image(item.item.imageAssetPath)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, height: 110)
                }
                
                // 2nd item (most left)
                if let item = viewModel.purchasedItemVisualized[safe: 1] {
                    Image(item.item.imageAssetPath)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, height: 110)
                        .offset(x: -60, y: 10)
                }

                // 3rd item (most right)
                if let item = viewModel.purchasedItemVisualized[safe: 2] {
                    Image(item.item.imageAssetPath)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, height: 110)
                        .offset(x: 60, y: 10)
                }
            }
            .offset(y: -90)
            
        }
    }
}

#Preview {
    PlayViewContainer()
}
