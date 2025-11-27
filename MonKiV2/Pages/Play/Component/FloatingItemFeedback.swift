//
//  FloatingItemFeedback.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 18/11/25.
//

import SwiftUI

struct FloatingItemFeedback: Identifiable, Equatable {
    let id: UUID // ID of the feedback object (for ForEach loop)
    let item: Item
    let startPoint: CGPoint
    let originPoint: CGPoint?
    let shouldFadeOut: Bool
    let trackedItemID: UUID // The ID of the original item that needs to be unhidden
}

struct FloatingItemFeedbackView: View {
    
    let id: UUID
    let item: Item
    let startPoint: CGPoint
    let originPoint: CGPoint?
    let trackedItemID: UUID // Used to notify the ViewModel which original item to unhide
    let onAnimationComplete: (UUID, UUID, Bool) -> Void // (fall.id, trackedItemID, shouldFadeOut)
    let shouldFadeOut: Bool
    
    @State private var animate = false
    @State private var isViewActive = true
    
    var body: some View {
        let (offsetX, offsetY, _): (CGFloat, CGFloat, Double) = {
            if let origin = originPoint {
                // Animate back to source of drag
                let xPos = origin.x - startPoint.x
                let yPos = origin.y - startPoint.y
                return (xPos, yPos, 0.0) // Return (No rotation)
            } else {
                // Fall to floor
                return (150.0, 200.0, 180.0) // Fall/Spin
            }
        }()
        
        if isViewActive {
            GroceryItemView(item: item)
                .position(startPoint)
                
                .offset(
                    x: animate ? offsetX : 0,
                    y: animate ? offsetY : 0
                )
                
                .opacity(animate ? (shouldFadeOut ? 0 : 1) : 1)
                
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        animate = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isViewActive = false
                        
                        onAnimationComplete(id, trackedItemID, shouldFadeOut)
                    }
                }
        }
    }
}
