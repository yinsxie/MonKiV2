//
//  ShoppingBagSideBarView.swift
//  MonKiV2
//
//  Created by William on 19/11/25.
//

import SwiftUI

struct ShoppingBagSideBarView: View {
    
    @Environment(CreateDishViewModel.self) var dishVM
    @Environment(CashierViewModel.self) var cashierVM
    @Environment(DragManager.self) var dragManager
    @Environment(PlayViewModel.self) var playVM
    
    let sideBarWidth: CGFloat = 408
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .trailing, spacing: 0) {
                if dishVM.isBagTapped {
                    ScrollView {
                        VStack(spacing: 40) {
                            ForEach(dishVM.groceriesList) { grocery in
                                GroceryDetailView(grocery: grocery)
                                    .makeDraggable(
                                        item: DraggedItem(
                                            id: grocery.item.id,
                                            payload: .grocery(grocery.item),
                                            source: .createDishOverlay
                                        )
                                    )
                                    .opacity(dragManager.currentDraggedItem?.id == grocery.item.id && grocery.quantity == 1 && dragManager.currentDraggedItem?.source == .createDishOverlay ? 0 : 1)
                            }
                        }
                    }
                    .frame(width: sideBarWidth)
                    .frame(maxHeight: .infinity)
                    .padding(.vertical, 45)
                    .background(Color.white.opacity(0.4))
                    .ignoresSafeArea()
                    .makeDropZone(type: .createDishOverlay)
                    .transition(.move(edge: .bottom))
                } else {
                    Spacer()
                }
                
                shoppingBagView
            }
            .zIndex(-1)
            .padding(.horizontal, 30)
        }
        .onChange(of: playVM.currentPageIndex, { _, newValue in
            if newValue == 5 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.toggleBag(to: true)
                }
            } else {
                if dishVM.isBagTapped {
                    toggleBag(to: false)
                }
            }
        })
    }
    
    @ViewBuilder
    var shoppingBagView: some View {
        Image("shopping_bag")
            .resizable()
            .scaledToFit()
            .frame(width: sideBarWidth)
            .onTapGesture {
                withAnimation(.easeOut(duration: 0.25)) {
                    dishVM.isBagTapped.toggle()
                }
            }
        .padding(.bottom, -200)
        .frame(maxWidth: .infinity, alignment: .bottomTrailing)
        .zIndex(1)
    }
    
    func toggleBag(to state: Bool?) {
        withAnimation(.easeOut(duration: 0.25)) {
            if let state = state {
                dishVM.isBagTapped = state
            } else {
                dishVM.isBagTapped.toggle()
            }
        }
    }
}

#Preview {
    PlayViewContainer()
}
