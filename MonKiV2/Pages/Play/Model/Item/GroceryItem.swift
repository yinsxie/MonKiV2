//
//  Grocery.swift
//  MonKiV2
//
//  Created by William on 19/11/25.
//
import Foundation

struct GroceryItem: Identifiable, Equatable {
    var id: UUID
    var item: Item
    var quantity: Int
}
