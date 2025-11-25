//
//  RotatingShineView.swift
//  MonKiV2
//
//  Created by William on 23/11/25.
//

import SwiftUI

struct RotatingShineView: View {
    
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            Image("bg_shine")
                .resizable()
                .scaledToFit()
                .scaleEffect(1.2)
                .rotationEffect(.degrees(rotationAngle))
            
            Image("bg_star")
                .resizable()
                .scaledToFit()
                .scaleEffect(0.8)
            
                .onAppear {
                    // Animate the rotationAngle from 0 to 360 degrees indefinitely
                    AudioManager.shared.play(.changeSound)
                    withAnimation(.linear(duration: 10.0).repeatForever(autoreverses: false)) {
                        rotationAngle = 360
                    }
                }
        }
    }
}

#Preview {
    RotatingShineView()
}
