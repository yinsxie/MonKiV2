//
//  PlayViewModel.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//

import SwiftUI

// this is basically God class PlayViewModel
@Observable class PlayEngine {
    var shelfVM = ShelfViewModel()
    var cartVM = CartViewModel()
    
    var dragManager = DragManager()
    
    init() {
        setupGameLogic()
    }
    
    private func setupGameLogic() {
        dragManager.onDropSuccess = { [weak self] zone, draggedItem in
            guard let self = self else { return }
            
            switch draggedItem.payload {
                
            case .grocery(let groceryItem):
                withAnimation(.spring) {
                    switch zone {
                    case .cart:
                        self.cartVM.addItem(groceryItem)
                        self.shelfVM.removeItem(withId: groceryItem.id)
                    case .cashierLoadingCounter:
                        print("Moved to cashier")
                    default: break
                    }
                }
            }
        }
    }
}
