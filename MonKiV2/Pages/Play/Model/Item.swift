//
//  Item.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import SwiftUI

struct Item {
    let id: UUID
    let name: String
    let price: Int
    let aisle: String?
    let imageAssetPath: String
    
    static let mockItem = Item(id: UUID(), name: "Test item", price: 10, aisle: nil, imageAssetPath: "")
    
    //TODO: Fill in the items here
    static let items: [Item] = [
        
    ]
}
