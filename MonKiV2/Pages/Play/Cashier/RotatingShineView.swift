//
//  RotatingShineView.swift
//  MonKiV2
//
//  Created by William on 23/11/25.
//

import SwiftUI

struct RotatingShineView: View {
    @State private var rotationAngle = 0.0
    @State private var hasPlayedSound = false

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
        }
        .onAppear {
            rotationAngle = 0
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
        .task {
            guard !hasPlayedSound else { return }
            hasPlayedSound = true
            AudioManager.shared.play(.changeSound)
        }
    }
}

#Preview {
    RotatingShineView()
}
