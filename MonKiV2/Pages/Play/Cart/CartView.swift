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
    
    private let maxRows = 3
    private let itemsPerRow = 5
    
    private var itemRows: [[CartItem]] {
        viewModel.items.chunked(into: itemsPerRow)
    }
    
    private var emptyRows: Int {
        max(0, maxRows - itemRows.count)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.8))
            
            VStack(alignment: .leading, spacing: -20) {

                ForEach(0..<emptyRows, id: \.self) { _ in
                    Color.clear
                        .frame(height: 50)
                }

                ForEach(itemRows.indices.reversed(), id: \.self) { index in
                    let row = itemRows[index]
                    
                    HStack(spacing: -20) {
                        ForEach(row) { cartItem in
                            GroceryItemView(item: cartItem.item)
                                .transition(.scale.combined(with: .opacity))
                                .makeDraggable(item: DraggedItem(id: cartItem.id,
                                                                 payload: .grocery(cartItem.item)))
                                .opacity(manager.currentDraggedItem?.id == cartItem.id ? 0.0 : 1.0)
                        }
                        
                    }
                }
            }
            .frame(width: 460, height: 280, alignment: .bottom)

        }
        .frame(width: 460, height: 280)
        .clipped()
        .makeDropZone(type: .cart)
    }
}

// Helper extension to chunk an array into smaller arrays
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

#Preview {
    var previewVM: CartViewModel {
        let vm = CartViewModel()
        
        let item1 = Item(id: UUID(), name: "Wortel", price: 3, aisle: "Sayur", imageAssetPath: "wortel")
        let item2 = Item(id: UUID(), name: "Tomat", price: 3, aisle: "Sayur", imageAssetPath: "tomat")
        let item3 = Item(id: UUID(), name: "Brokoli", price: 4, aisle: "Sayur", imageAssetPath: "brokoli")
        let item4 = Item(id: UUID(), name: "Jagung", price: 3, aisle: "Sayur", imageAssetPath: "jagung")
        let item5 = Item(id: UUID(), name: "Telur", price: 5, aisle: "Protein Harian", imageAssetPath: "")
        
        // Add 5 items to test stacking
        vm.addItem(item1)
        vm.addItem(item2)
        vm.addItem(item3)
        vm.addItem(item4)
        vm.addItem(item5)
        
        return vm
    }
    let previewManager = DragManager()
    
    return CartView(viewModel: previewVM)
        .environment(previewManager)
        .padding()
}
