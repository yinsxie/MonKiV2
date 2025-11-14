//
//  CartView.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//
import SwiftUI

struct CartView: View {
    var viewModel: CartViewModel
    @Environment(DragManager.self) var manager
    
    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.8))
                .frame(width: 300, height: 120)
                .shadow(radius: 5)
            
            HStack(spacing: -10) {
                ForEach(viewModel.items) { cartItem in

                    GroceryItemView(item: cartItem.item)
                    .scaleEffect(0.8)
                    .frame(width: 50, height: 50)
                    .shadow(radius: 2)
                    .transition(.scale.combined(with: .opacity))

                    .makeDraggable(item: DraggedItem(id: cartItem.id,
                                                    payload: .grocery(cartItem.item)))
                    .opacity(manager.currentDraggedItem?.id == cartItem.id ?  0 : 1)
                }
            }
            .padding(.bottom, 40)
            
            Text("My Cart")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 10)
        }
        .makeDropZone(type: .cart)
    }
}
