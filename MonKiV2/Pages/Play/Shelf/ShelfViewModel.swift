//
//  ShelfViewModel.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//
import SwiftUI

@Observable class ShelfViewModel {
    weak var parent: PlayViewModel?

    init(parent: PlayViewModel?) {
        self.parent = parent
    }
    
    var items: [Item] = Item.items
   
    var isSecondShelfLeftFridgeOpen: Bool = false
    var isSecondShelfRightFridgeOpen: Bool = false

    func animateLeftDoor() {
        withAnimation(.easeOut(duration: 0.5)) {
            isSecondShelfLeftFridgeOpen.toggle()
        }
    }
    
    func animateRightDoor() {
        withAnimation(.easeOut(duration: 0.5)) {
            isSecondShelfRightFridgeOpen.toggle()
        }
    }
}
