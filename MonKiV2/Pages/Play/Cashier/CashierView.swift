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
    
    @State private var bubbleOpacity: Double = 0
    
    var body: some View {
        ZStack {
            
            // LEFT SIDE — DISCARD BIN
            HStack(spacing: 0) {
                
                ZStack {
                    Image("discard_bin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 251)
                        .offset(y: -40)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(ColorPalette.green200)
                        .opacity(0)         // debug: set to 0.3 to see the area
                        .frame(width: 245, height: 280)
                        .offset(y: 100)
                        .makeDropZone(type: .cashierRemoveItem)
                }
                .padding(.horizontal, 40)
                
                Spacer()
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
                    HStack {
                        ForEach(viewModel.checkOutItems) { cartItem in
                            GroceryItemView(item: cartItem.item)
                                .scaleEffect(1)
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
                                    dragManager.currentDraggedItem?.id == cartItem.id
                                    ? 0 : 1
                                )
                                .padding(.horizontal, -20)
                        }
                    }
                    .environment(\.layoutDirection, .rightToLeft)
                    .padding(.leading, 0)
                }
                .frame(maxWidth: 460, alignment: .leading)
                .padding(.top, 82)
                .makeDropZone(type: .cashierLoadingCounter)
                .offset(y: -95)
                .zIndex(1)
                
                // CASHIER IMAGE
                
                ZStack {
                    Image("cashier_counter")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 706)
                        .ignoresSafeArea()
                    
                    Image("basket")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 232.46)
                        .offset(x: 850, y: 170)
                    
                    ZStack {
                        ZStack {
                            Image("cashier_monki")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 370)
                                .offset(x: -230, y: -110)
                            
                            ZStack(alignment: .center) {
                                Image("speech_bubble")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 202)
                                
                                if viewModel.isPaymentSufficient {
                                    ZStack {
                                        Rectangle()
                                            .fill(ColorPalette.green500)
                                            .frame(width: 85, height: 60)
                                        
                                        Text("\(viewModel.totalPrice)")
                                            .font(.custom("WendyOne-Regular", size: 40))
                                            .foregroundStyle(.white)
                                    }
                                    .offset(x: 10)
                                } else {
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .foregroundStyle(Color(hex: "#D84942"))
                                        .offset(x: 10)
                                }
                            }
                            .offset(x: -110, y: -280)
                            .opacity(bubbleOpacity)
                        }
                        .onChange(of: viewModel.currentPage) { _, newPage in
                            if viewModel.totalPrice > 0 && newPage == .payment {
                                // Fade IN — 1.5 seconds
                                withAnimation(.easeInOut(duration: 1.2)) {
                                    bubbleOpacity = 1
                                }
                            } else {
                                // Fade OUT — default (fast)
                                withAnimation(.easeOut(duration: 0.1)) {
                                    bubbleOpacity = 0
                                }
                            }
                        }
                        .onChange(of: viewModel.totalPrice) { _, newTotalPrice in
                            if newTotalPrice == 0 {
                                withAnimation(.easeOut(duration: 0.1)) {
                                    bubbleOpacity = 0
                                }
                            }
                        }
                        .scrollTransition(.animated, axis: .horizontal) { content, phase in
                            content
                                .offset(x: phase.isIdentity ? 0 : 520)
                        }
                        
                        Image("cashier_register")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                            .offset(x: 50, y: -92.5)
                        
                        Text("\(viewModel.totalPrice)")
                            .font(.VT323(size: 40))
                            .offset(x: 180, y: -169)
                            .foregroundStyle(Color(hex: "#89E219"))
                        
                        ShoppingBagView()
                            .offset(x: 520, y: 27)
                    }
                    
                    // Money DropZone
                    // Edge Case: Make sure the drop zone is only active on the payment page
                    Color.green.opacity(0)
                        .frame(width: 465, height: 406)
                        .contentShape(Rectangle())
                        .makeDropZone(type: .cashierPaymentCounter)
                        .offset(x: 450)
                        .scrollTransition { content, phase in
                            content.offset(x: phase.isIdentity ? 140 : 0)
                        }
                }
            }
            .padding(.top, -120) // replaces offset(y: -120)
            .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                content.offset(x: phase.isIdentity ? 350 : 600)
            }
        }
    }
}

#Preview {
    PlayViewContainer()
}
