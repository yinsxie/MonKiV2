//
//  MonkiLoadingView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 01/12/25.
//

import SwiftUI

struct MonkiLoadingView: View {
    
    // MARK: - State
    @State private var isAnimating: Bool = false
    private let animDuration: Double = 8.0
    private let playerHeight: CGFloat = 300
    
    var body: some View {
        ZStack {
            Image("icon_multi_online_black")
                .resizable()
                .scaledToFit()
                .frame(width: 700)
                .opacity(0.5)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(getSpinAnimation(), value: isAnimating)
            
            HStack(spacing: 80) {
                Image("monki_multi_full_active_player1_1")
                    .resizable()
                    .scaledToFit()
                    .frame(height: playerHeight)

                Image("monki_multi_full_active_player2")
                    .resizable()
                    .scaledToFit()
                    .frame(height: playerHeight)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    // MARK: - Helpers
    private func getSpinAnimation() -> Animation {
        .linear(duration: animDuration)
        .repeatForever(autoreverses: false)
    }
    
    private func startAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isAnimating = true
        }
    }
}

#Preview {
    ZStack {
        Color.blue.opacity(0.2).ignoresSafeArea()
        MonkiLoadingView()
    }
}
