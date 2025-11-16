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
    
}
