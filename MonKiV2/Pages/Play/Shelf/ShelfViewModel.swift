//
//  ShelfViewModel.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//
import SwiftUI

@Observable class ShelfViewModel {
    var items: [Item] = Item.items

    func removeItem(withId itemID: UUID) {
        items.removeAll { $0.id == itemID }
    }
}
