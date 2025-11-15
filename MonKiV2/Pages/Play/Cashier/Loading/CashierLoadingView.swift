//
//  CashierLoadingView.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import SwiftUI

struct CashierLoadingView: View {
    @Environment(CashierViewModel.self) var viewModel
    @Environment(DragManager.self) var dragManager
    
    var body: some View {
        ZStack {
            
            HStack(spacing: 0) {
                
                // LEFT SIDE — GREEN + DISCARD BOX
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(ColorPalette.blue200)
                        .frame(width: 250, height: 250)  // slightly smaller
                        .makeDropZone(type: .cashierRemoveItem)
                    
                    Text("Discard Here")
                }
                .padding(.horizontal, 100)
                Spacer()
            }
            
            ZStack(alignment: .leading) { // 3️⃣ Make red background top area
                
                ZStack(alignment: .bottomTrailing) {
                    Color.green.opacity(0.2)
                        .frame(width: 660, height: 250)

                    HStack {
                        ForEach(viewModel.checkOutItems) { cartItem in
                            GroceryItemView(item: cartItem.item)
                            .scaleEffect(0.8)
                            .frame(width: 50, height: 50)
                            .shadow(radius: 2)
                            .transition(.scale.combined(with: .opacity))
                            .padding(.vertical, 20)
                            .padding(.horizontal, 8)
                            .makeDraggable(item: DraggedItem(id: cartItem.id, payload: .grocery(cartItem.item), source: .cashierCounter))
                            .opacity(dragManager.currentDraggedItem?.id == cartItem.id ? 0.0 : 1.0)
                        }
                    }
                    .environment(\.layoutDirection, .rightToLeft)
                }
                .frame(width: 660, alignment: .trailing)
                .offset(y: -82)
                .makeDropZone(type: .cashierLoadingCounter)
                .zIndex(1)
                
                Image("Cashier")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 735)
                    .ignoresSafeArea()
            }
            .offset(x: 550)
        }
    }
}

#Preview {
    PlayViewContainer()
}
