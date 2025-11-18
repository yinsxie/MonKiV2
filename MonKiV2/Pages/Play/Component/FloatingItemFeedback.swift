//
//  FloatingItemFeedback.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 18/11/25.
//

import SwiftUI

struct FloatingItemFeedback: Identifiable, Equatable {
    let id = UUID()
    let item: Item
    let startPoint: CGPoint
    let originPoint: CGPoint?
}

struct FloatingItemFeedbackView: View {
    
    let item: Item
    let startPoint: CGPoint
    let originPoint: CGPoint?
    let onAnimationComplete: () -> Void
    
    @State private var animate = false
    
    var body: some View {
        let (offsetX, offsetY, rotation): (CGFloat, CGFloat, Double) = {
            if let origin = originPoint {
                // Animate back to source of drag
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
            
            .offset(
                x: animate ? offsetX : 0,
                y: animate ? offsetY : 0
            )
            
//            .rotationEffect(.degrees(animate ? 180 : 0)) // Spin it
            .opacity(animate ? 0 : 1) // Fade it out
            
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8)) {
                    animate = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    onAnimationComplete()
                }
            }
    }
}
