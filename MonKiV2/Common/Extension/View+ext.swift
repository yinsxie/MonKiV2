//
//  Untitled.swift
//  MonKiV2
//
//  Created by William on 30/11/25.
//

import SwiftUI

struct RotatingModifier: ViewModifier {
    let duration: Double
    let enabled: Bool
    @State private var isRotating = false
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(isRotating && enabled ? 360 : 0))
            .animation(
                enabled
                ? .linear(duration: duration).repeatForever(autoreverses: false)
                : .default,  // no animation when disabled
                value: isRotating && enabled
            )
            .onAppear {
                if enabled {
                    isRotating = true
                }
            }
            .onChange(of: enabled) { old, newValue in
                if newValue {
                    isRotating = true    // start spinning
                } else {
                    isRotating = false   // stop spinning
                }
            }
    }
}

extension View {
    func rotating(duration: Double = 1.0, enabled: Bool = true) -> some View {
        self.modifier(RotatingModifier(duration: duration, enabled: enabled))
    }
}
