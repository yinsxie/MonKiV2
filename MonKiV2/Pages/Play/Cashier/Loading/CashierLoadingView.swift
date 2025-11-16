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
    @Environment(PlayViewModel.self) var playViewModel
    
    let discardBinImage: String = "DiscardBin"
    
    var body: some View {
        ZStack {
            
            // LEFT SIDE — DISCARD BIN
            HStack(spacing: 0) {
                
                ZStack {
                    Image(discardBinImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 210)
                        .offset(y: -40)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(ColorPalette.green200)
                        .opacity(0)         // debug: set to 0.3 to see the area
                        .frame(width: 210, height: 235)
                        .offset(y: 80)
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
                        .frame(width: 460, height: 150)
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
                .offset(y: -80)
                .zIndex(1)
                
                // CASHIER IMAGE
                
                ZStack {
                    Image("Cashier")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 706)
                        .ignoresSafeArea()
                    
                    ZStack {
                        Image("monki_cashier")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 370)
                            .offset(x: -230, y: -110)
                            .scrollTransition(.animated, axis: .horizontal) { content, phase in
                                content.offset(x: phase.isIdentity ? 0 : 520)
                            }
                        
                        Image("Register")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                            .offset(x: 50, y: -92.5)
                        
                        Text("\(viewModel.totalPrice)")
                            .font(.VT323(size: 40))
                            .offset(x: 180, y: -169)
                            .foregroundStyle(Color(hex: "#89E219"))
                    }
                }
            }
            .padding(.top, -120) // replaces offset(y: -40)
            
            // SCROLL TRANSITION
            .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                content.offset(x: phase.isIdentity ? 350 : 600)
            }
        }
    }
}

#Preview {
    PlayViewContainer()
}
