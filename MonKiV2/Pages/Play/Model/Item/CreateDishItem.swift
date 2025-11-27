//
//  CreateDishItem.swift
//  MonKiV2
//
//  Created by William on 19/11/25.
//

import Foundation

struct CreateDishItem: Identifiable, Equatable {
    var id: UUID
    var item: Item
    var position: CGPoint
    
    init(item: Item, position: CGPoint?) {
        self.id = item.id
        self.item = item
        self.position = position ?? CGPoint(x: 0, y: 0)
    }
}
