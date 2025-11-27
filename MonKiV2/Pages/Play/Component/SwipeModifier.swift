//
//  SwipeModifier.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 27/11/25.
//

import SwiftUI

// MARK: - 1. Swipe Modifier (Buka & Tutup)
struct ComponentSwipeModifier: ViewModifier {
    var onOpen: () -> Void
    var onClose: () -> Void
    
    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .onEnded { value in
                        let verticalMovement = value.translation.height
                        
                        // Swipe Up -> Buka
                        if verticalMovement < -30 {
                            onOpen()
                        }
                        // Swipe Down -> Tutup
                        else if verticalMovement > 30 {
                            onClose()
                        }
                    }
            )
    }
}

// MARK: - 2. Header Close Modifier (Tutup)
struct HeaderCloseSwipeModifier: ViewModifier {
    var onClose: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.height > 60 &&
                           value.translation.height > abs(value.translation.width) {
                            onClose()
                        }
                    }
            )
    }
}

// MARK: - View Extension agar pemakaian lebih mudah
extension View {
    func onComponentSwipe(open: @escaping () -> Void, close: @escaping () -> Void) -> some View {
        self.modifier(ComponentSwipeModifier(onOpen: open, onClose: close))
    }
    
    func onHeaderCloseSwipe(close: @escaping () -> Void) -> some View {
        self.modifier(HeaderCloseSwipeModifier(onClose: close))
    }
}
