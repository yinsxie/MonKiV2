//
//  LoadingAnimationView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 01/12/25.
//

import SwiftUI

struct LoadingAnimationView: View {
    
    // MARK: - Enums
    enum Variant {
        case vegetables
        case base
    }
    
    // MARK: - Properties
    var variant: Variant = .vegetables
    
    @State private var isAnimating = false
    
    // MARK: - Configuration
    private let bounceHeight: CGFloat = -20
    private let bounceScale: CGFloat = 1.1
    private let animationDuration: Double = 0.5
    private let staggerDelay: Double = 0.1
    
    // MARK: - Data
    private let loadingItems: [Item] = [
        Item(id: UUID(), name: "Jagung", price: 0, aisle: nil, imageAssetPath: "jagung"),
        Item(id: UUID(), name: "Telur", price: 0, aisle: nil, imageAssetPath: "telur"),
        Item(id: UUID(), name: "Tomat", price: 0, aisle: nil, imageAssetPath: "tomat"),
        Item(id: UUID(), name: "Wortel", price: 0, aisle: nil, imageAssetPath: "wortel"),
        Item(id: UUID(), name: "Brokoli", price: 0, aisle: nil, imageAssetPath: "brokoli")
    ]
    
    private let baseItems: [Item] = [
        Item(id: UUID(), name: "Rice", price: 6, aisle: "Pokok", imageAssetPath: "nasi"),
        Item(id: UUID(), name: "Pasta", price: 6, aisle: "Pokok", imageAssetPath: "mie"),
        Item(id: UUID(), name: "Bread", price: 7, aisle: "Pokok", imageAssetPath: "roti")
    ]
    
    private var displayedItems: [Item] {
        switch variant {
        case .vegetables:
            return loadingItems
        case .base:
            return baseItems
        }
    }
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(Array(displayedItems.enumerated()), id: \.offset) { index, item in
                animatedItemView(item, index: index)
            }
        }
        .onAppear {
            startAnimation()
        }
        .onChange(of: variant) { _ in
            startAnimation()
        }
    }
    
    // MARK: - Subviews
    private func animatedItemView(_ item: Item, index: Int) -> some View {
        GroceryItemView(item: item)
            .scaleEffect(0.7)
            .offset(y: isAnimating ? bounceHeight : 0)
            .scaleEffect(isAnimating ? bounceScale : 1.0)
            .animation(
                Animation
                    .easeInOut(duration: animationDuration)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * staggerDelay),
                value: isAnimating
            )
    }
    
    // MARK: - Logic
    private func startAnimation() {
        isAnimating = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isAnimating = true
        }
    }
}

// MARK: - Preview Updates
#Preview {
    VStack(spacing: 50) {
        Text("Variant: Vegetables")
        LoadingAnimationView(variant: .vegetables)
        
        Divider()
        
        Text("Variant: Staples")
        LoadingAnimationView(variant: .base)
    }
}
