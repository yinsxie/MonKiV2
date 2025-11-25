//
//  GroceryItemView.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//
import SwiftUI

struct GroceryItemView: View { // this is created so that item on shelf and after clicked stays consistent
    let item: Item
    
    var body: some View {
        // TODO: Change with actual asset
        if item.imageAssetPath == "" {
            Rectangle()
                .fill(Color.gray.opacity(0.8))
                .border(Color.black, width: 1)
//                .frame(width: 100, height: 100)
                .overlay(
                    Text(item.name)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(5)
                )
        } else {
            Image(item.imageAssetPath)
                .resizable()
                .scaledToFit()
                .frame(width: 110, height: 110)
        }
        
    }
}

#Preview {
    PlayViewContainer(forGameMode: .singleplayer)
        .environmentObject(AppCoordinator())
}
