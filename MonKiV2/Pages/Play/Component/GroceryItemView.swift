//
//  GroceryItemView.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//
import SwiftUI

struct GroceryItemView: View { // this is created so that item on shelf and after clicked stays consistent
    let item: GroceryItem
    
    var body: some View {
        VStack {
            // TODO: Change with actual item asset string
            Image(systemName: item.icon)
                .font(.system(size: 40))
                .foregroundColor(.orange)
        }
        .shadow(radius: 3)
    }
}
