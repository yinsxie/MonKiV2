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
    @Environment(CartViewModel.self) var cartVM
    @Environment(PlayViewModel.self) var playVM
    
    private let chocolateItem = Item.items.first { $0.name == "Chocolate" }
    private let sausageItem = Item.items.first { $0.name == "Sausage" }
    
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
                        
                        if let index = playViewModel.currentPageIndex, playViewModel.getPage(at: index) == .cashierLoading {
                            Rectangle()
                                .foregroundColor(Color.clear)
                                .floatingPriceFeedback(value: viewModel.discardedAmountTracker)
                                .frame(width: 100, height: 100)
                                .offset(x: 70, y: -30)
                        }
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
                        .padding(.bottom, -10)
                        .padding(.horizontal, 30)
                        .offset(x: -80)
                    }
                    .frame(maxWidth: 700, alignment: .leading)
                    .padding(.top, 82)
                    .makeDropZone(type: .cashierLoadingCounter)
                    //                                        .background(Color.green.opacity(0.5))
                    .offset(y: -95)
                    .zIndex(1)
                    
                    // CASHIER IMAGE
                    ZStack {
                        ZStack {
                            Image("trolley_sign")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 517)
                                .offset(x: -450, y: -70)
                            
                            CashierMonkiView()
                                .opacity(viewModel.isStartingReturnMoneyAnimation ? 0 : 1)
                                .scrollTransition(.animated, axis: .horizontal) { content, phase in
                                    content
                                        .offset(x: phase.isIdentity ? 0 : 1000, y: 200)
                                }
                                .onTapGesture {
                                    viewModel.onReturnedReceivedMoneyTapped()
                                }
                                .onChange(of: playVM.currentPageIndex) {
                                    if playVM.getCurrentPage() != .cashierPayment {
                                        viewModel.onPageChangeWhileReceivedMoney()
                                    }
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
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                            
                            Image("Icon_cashier_1_active")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .offset(x: -160, y: -70)
                            
                            Image("scan_light")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 190)
                                .offset(x: -270, y: -40)
                                .opacity(viewModel.isScanning ? 1 : 0)
                                .animation(.easeInOut(duration: 0.1), value: viewModel.isScanning)
                        }
                        
                        Image("cashier_counter")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 1622.78, height: 706)
                            .offset(y: 195)
                            .ignoresSafeArea()
                        // Mini shelf
                        ZStack(alignment: .bottomLeading) {
                            Image("cashier_shelf")
                                .resizable()
                                .scaledToFit()
                            
                            HStack(spacing: 0) {
                                // Chocolate
                                if let chocolateItem = chocolateItem {
                                    Color.green.opacity(0.001)
                                        .makeDraggable(
                                            item: DraggedItem(
                                                payload: .grocery(chocolateItem),
                                                source: .cashierShelf
                                            )
                                        )
                                        .makeDropZone(type: .shelfReturnItem)
                                }
                                
                                // Sausage
                                if let sausageItem = sausageItem {
                                    Color.green.opacity(0.001)
                                        .makeDraggable(
                                            item: DraggedItem(
                                                payload: .grocery(sausageItem),
                                                source: .cashierShelf
                                            )
                                        )
                                        .makeDropZone(type: .shelfReturnItem)
                                }
                            }
                            .frame(maxHeight: .infinity)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 10)
                        }
                        .frame(width: 391, height: 265)
                        .offset(x: -220, y: 220)
                        
                        // Money DropZone
                        // Edge Case: Make sure the drop zone is only active on the payment page
                        Color.green.opacity(0)
                            .frame(width: 680, height: 406)
                            .contentShape(Rectangle())
                            .makeDropZone(type: .cashierPaymentCounter)
                        //                                                    .background(Color.green.opacity(0.5))
                            .offset(x: 480)
                            .scrollTransition { content, phase in
                                content.offset(x: phase.isIdentity ? 140 : 0)
                            }
                            .allowsHitTesting(false)
                    }
                }
                
                ShoppingBagView(items: viewModel.bagVisualItems)
                    .padding(.horizontal, 20)
                    .offset(x: viewModel.bagOffset)
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
    PlayViewContainer(forGameMode: .singleplayer)
}
