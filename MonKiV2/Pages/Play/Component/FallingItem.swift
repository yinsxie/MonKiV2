//
//  FallingItem.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 18/11/25.
//

import SwiftUI

struct FallingItemView: View {
    
    let item: Item
    let startPoint: CGPoint
    let originPoint: CGPoint? // 1. Add this property
    let onAnimationComplete: () -> Void // A way to tell the VM to delete this
    
    // 1. Animation State
    @State private var animate = false
    
    var body: some View {
        let (offsetX, offsetY, rotation): (CGFloat, CGFloat, Double) = {
            if let origin = originPoint {
                // Animate back to shelf
                let x = origin.x - startPoint.x
                let y = origin.y - startPoint.y
                return (x, y, 0.0) // No rotation
            } else {
                // Fall to floor
                return (150.0, 200.0, 180.0)
            }
        }()
        
        GroceryItemView(item: item)
            .position(startPoint) // Start at the drop location
            
            // --- 2. ADD THIS MODIFIER FOR THE "U-SHAPE" ---
            .offset(
                x: animate ? offsetX : 0, // Moves 150 points to the right
                y: animate ? offsetY : 0  // Moves 200 points down
            )
            
//            .rotationEffect(.degrees(animate ? 180 : 0)) // Spin it
            .opacity(animate ? 0 : 1) // Fade it out
            
            // 3. Run the animation on appear
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8)) {
                    animate = true
                }
                
                // 4. After the animation, tell the VM to remove this item
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    onAnimationComplete()
                }
            }
    }
}
