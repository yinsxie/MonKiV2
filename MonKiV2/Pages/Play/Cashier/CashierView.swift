//
//  CashierLoadingView.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import SwiftUI

struct CashierView: View {
    @Environment(CashierViewModel.self) var viewModel
    @Environment(DragManager.self) var dragManager
    @Environment(PlayViewModel.self) var playViewModel
    
    var body: some View {
        
        HStack(alignment: .bottom) {
            HStack(alignment: .bottom, spacing: 0) {
                // LEFT SIDE — DISCARD BIN
                HStack(spacing: 0) {
                    
                    ZStack {
                        Image("discard_bin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 251)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(ColorPalette.green200)
                            .opacity(0)         // debug: set to 0.3 to see the area
                            .frame(width: 245, height: 280)
                            .offset(y: 140)
                            .makeDropZone(type: .cashierRemoveItem)
                    }
                    .padding(.trailing, 30)
                    
                }
                
                // MAIN COUNTER AREA
                ZStack(alignment: .leading) {
                    
                    // COUNTER BACKGROUND + ITEMS
                    ZStack(alignment: .bottomTrailing) {
                        
                        // GREEN BACKGROUND BAR (left-aligned)
                        Color.green
                            .opacity(0)
                            .frame(width: 550, height: 200)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // ITEMS FROM RIGHT → LEFT
                        VStack(alignment: .trailing, spacing: -50) {
                            // 2nd Row (Top/Back) - Items 10 to 12
                            if viewModel.checkOutItems.count > 7 {
                                HStack {
                                    ForEach(Array(viewModel.checkOutItems.dropFirst(7))) { cartItem in
                                        GroceryItemView(item: cartItem.item)
                                            .scaleEffect(0.85)
                                            .shadow(radius: 2)
                                            .transition(.scale.combined(with: .opacity))
                                            .makeDraggable(
                                                item: DraggedItem(
                                                    id: cartItem.id,
                                                    payload: .grocery(cartItem.item),
                                                    source: .cashierCounter
                                                )
                                            )
                                            .opacity(
                                                dragManager.currentDraggedItem?.id == cartItem.id ||
                                                playViewModel.itemsCurrentlyAnimating.contains(cartItem.id)
                                                ? 0 : 1
                                            )
                                            .padding(.horizontal, -25)
                                    }
                                }
                                .environment(\.layoutDirection, .rightToLeft)
                                .padding(.trailing, 80)
                            }
                            
                            // 1st Row (Bottom/Front) - Items 1 to 9
                            HStack {
                                ForEach(Array(viewModel.checkOutItems.prefix(7))) { cartItem in
                                    GroceryItemView(item: cartItem.item)
                                        .scaleEffect(0.85)
                                        .shadow(radius: 2)
                                        .transition(.scale.combined(with: .opacity))
                                        .makeDraggable(
                                            item: DraggedItem(
                                                id: cartItem.id,
                                                payload: .grocery(cartItem.item),
                                                source: .cashierCounter
                                            )
                                        )
                                        .opacity(
                                            dragManager.currentDraggedItem?.id == cartItem.id ||
                                            playViewModel.itemsCurrentlyAnimating.contains(cartItem.id)
                                            ? 0 : 1
                                        )
                                        .padding(.horizontal, -25)
                                }
                            }
                            .environment(\.layoutDirection, .rightToLeft)
                        }
                        .padding(.horizontal, 10)
                    }
                    .frame(maxWidth: 620, alignment: .leading)
                    .padding(.top, 82)
                    .makeDropZone(type: .cashierLoadingCounter)
                    //                    .background(Color.green.opacity(0.5))
                    .offset(y: -95)
                    .zIndex(1)
                    
                    // CASHIER IMAGE
                    ZStack {
                        Image("cashier_counter")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 1622.78, height: 706)
                            .ignoresSafeArea()
                        
                        ZStack {
                            CashierMonkiView()
                                .opacity(viewModel.isReturnedMoneyPrompted ? 0 : 1)
                                .scrollTransition(.animated, axis: .horizontal) { content, phase in
                                    content
                                        .offset(x: phase.isIdentity ? 0 : 1000)
                                }
                                .onTapGesture {
                                    viewModel.onReturnedReceivedMoneyTapped()
                                }
                            
                            Image("cashier_register")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 317)
                                .offset(x: 40, y: -115)
                            
                            Text("\(viewModel.totalPrice)")
                                .font(.VT323(size: 40))
                                .offset(x: 157.5, y: -212.5)
                                .foregroundStyle(ColorPalette.cashierNominal)
                        }
                        
                        // Money DropZone
                        // Edge Case: Make sure the drop zone is only active on the payment page
                        Color.green.opacity(0)
                            .frame(width: 465, height: 406)
                            .contentShape(Rectangle())
                            .makeDropZone(type: .cashierPaymentCounter)
                        //                            .background(Color.green.opacity(0.5))
                            .offset(x: 450)
                            .scrollTransition { content, phase in
                                content.offset(x: phase.isIdentity ? 140 : 0)
                            }
                    }
                }
                
                ShoppingBagView()
                    .padding(.horizontal, 20)
            }
            .frame(alignment: .leading)
            
            .padding(.leading, -35)
            .padding(.bottom, 120)
            .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                content.offset(x: phase.isIdentity ? 0 : 320)
            }
        }
        .frame(width: 2732, height: 1024, alignment: .leading)
    }
}

#Preview {
    PlayViewContainer()
}
