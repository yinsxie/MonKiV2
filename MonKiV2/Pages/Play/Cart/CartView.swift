//
//  CartView.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//
import SwiftUI

struct CartView: View {
    @Environment(CartViewModel.self) var viewModel
    @Environment(DragManager.self) var manager
    
    private let maxRows = 3
    private let itemsPerRow = 4
    private let rowHeight: CGFloat = 120
    private let indentPerRow: CGFloat = 30.0
    
    private var itemRows: [[CartItem]] {
        viewModel.items.chunked(into: itemsPerRow)
    }
    
    private var emptyRows: Int {
        max(0, maxRows - itemRows.count)
    }

    var body: some View {
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
                        }
                    }
                    .frame(height: rowHeight)
//                    .border(Color.blue, width: 5)
                    .padding(.leading, CGFloat(index) * (2-indentPerRow))
//                    .border(Color.yellow, width: 5)
                }
            }
//            .background(Color.green.opacity(0.8))
            .frame(maxWidth: 350)
            .padding(.bottom, 200)
            .padding(.trailing, 0)
            .padding(.leading, 120)
            
            Image("cart")
                .resizable()
                .scaledToFit()
                .frame(width: 581, alignment: .bottom)
                .allowsHitTesting(false)
        }
        .frame(width: 581, alignment: .bottom)
//        .border(Color.green, width: 5)
        .clipped()
        .makeDropZone(type: .cart)
    }
}

#Preview {
    PlayViewContainer()
        .environmentObject(AppCoordinator())
}
