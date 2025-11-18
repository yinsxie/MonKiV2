//
//  CartView.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//
import SwiftUI

struct CartView: View {
    @Environment(CartViewModel.self) var cartVM
    @Environment(PlayViewModel.self) var playVM
    @Environment(DragManager.self) var manager
    
    private let maxRows = 3
    private let itemsPerRow = 4
    private let rowHeight: CGFloat = 120
    private let indentPerRow: CGFloat = 30.0
    
    private var priceColor: Color {
        if cartVM.totalPrice > playVM.currentBudget {
            return Color(hex: "#CD4947")
        } else {
            return Color(hex: "#65C466")
        }
    }
    
    private var itemRows: [[CartItem]] {
        cartVM.items.chunked(into: itemsPerRow)
    }
    
    private var emptyRows: Int {
        max(0, maxRows - itemRows.count)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            
            // LAYER 1: THE DROP ZONE (STATIC)
            Color.clear
                .contentShape(Rectangle())
                .makeDropZone(type: .cart)
                .frame(width: 581, height: 550)
            
            // LAYER 2: THE VISUALS (ANIMATED)
            cartVisuals
                .geometryGroup()
                
                .keyframeAnimator(initialValue: 0.0, trigger: cartVM.shakeTrigger) { content, value in
                    content.offset(x: value)
                } keyframes: { _ in
                    KeyframeTrack {
                        CubicKeyframe(0, duration: 0.01)
                        CubicKeyframe(-10, duration: 0.1)
                        CubicKeyframe(10, duration: 0.1)
                        CubicKeyframe(-10, duration: 0.1)
                        CubicKeyframe(0, duration: 0.1)
                    }
                }
        }
        .frame(width: 581, height: 550, alignment: .bottom)
    }
    
    private var cartVisuals: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: -30) {
                ForEach(0..<emptyRows, id: \.self) { _ in
                    Color.clear
                        .frame(height: rowHeight)
                }
                ForEach(itemRows.indices.reversed(), id: \.self) { index in
                    let row = itemRows[index]
                    HStack(alignment: .firstTextBaseline, spacing: -30) {
                        ForEach(row) { cartItem in
                            GroceryItemView(item: cartItem.item)
                                .transition(.scale.combined(with: .opacity))
                                .makeDraggable(item: DraggedItem(id: cartItem.id, payload: .grocery(cartItem.item), source: .cart))
                                .opacity(manager.currentDraggedItem?.id == cartItem.id ? 0.0 : 1.0)
                        }
                    }
                    .frame(height: rowHeight)
                    .padding(.leading, CGFloat(index) * (2-indentPerRow))
                }
            }
            .frame(maxWidth: 350)
            .padding(.bottom, 200)
            .padding(.trailing, 0)
            .padding(.leading, 120)
            
            ZStack(alignment: .center) {
                Image("cart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 581)
                    .aspectRatio(contentMode: .fit)
                
                Rectangle()
                    .foregroundColor(priceColor)
                    .frame(width: 172, height: 47)
                    .overlay(
                        Text("\(cartVM.totalPrice)")
                            .font(.wendyOne(size: 40))
                            .foregroundColor(Color.white)
                        )
                    .offset(x: 65, y: -45)
            }
            .allowsHitTesting(false)
        }
        .frame(width: 581, height: 550, alignment: .bottom)
    }
}

#Preview {
    PlayViewContainer()
        .environmentObject(AppCoordinator())
}
