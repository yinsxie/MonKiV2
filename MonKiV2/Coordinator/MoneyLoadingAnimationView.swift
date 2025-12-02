//
//  MoneyLoadingAnimationView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 01/12/25.
//

import SwiftUI

struct MoneyLoadingAnimationView: View {
    
    // MARK: - State
    @State private var breakdownData: BreakdownResult?
    @State private var isAnimating: Bool = false
    
    // MARK: - Constants
    private let bounceHeight: CGFloat = -15
    private let animDuration: Double = 0.5
    private let moneyWidth: CGFloat = 170
    
    var body: some View {
        HStack(spacing: 4) {
            if let data = breakdownData {
                animatedMoney(currency: data.source, index: 0)
                
                Text("=")
                    .font(.fredokaMedium(size: 40))
                    .foregroundColor(ColorPalette.playWithFriendTitle)
                    .shadow(radius: 2)
                    .padding(.horizontal, 4)
                    .offset(y: isAnimating ? bounceHeight : 0)
                    .animation(getAnimation(delay: 0.1), value: isAnimating)
                
                ForEach(Array(data.targets.enumerated()), id: \.offset) { index, currency in
                    HStack(spacing: 4) {
                        if index > 0 {
                            Text("+")
                                .font(.fredokaSemiBold(size: 30))
                                .foregroundColor(ColorPalette.playWithFriendTitle)
                                .offset(y: isAnimating ? bounceHeight : 0)
                                .animation(getAnimation(delay: 0.2 + (Double(index) * 0.05)), value: isAnimating)
                        }
                        
                        animatedMoney(currency: currency, index: index + 2)
                    }
                }
            }
        }
        .onAppear {
            setupRandomEquation()
        }
    }
    
    // MARK: - Component Builders
    private func animatedMoney(currency: Currency, index: Int) -> some View {
        MoneyView(
            money: Money(forCurrency: currency),
            quantity: 1,
            width: moneyWidth
        )
        .scaleEffect(0.8)
        .offset(y: isAnimating ? bounceHeight : 0)
        .animation(getAnimation(delay: Double(index) * 0.1), value: isAnimating)
    }
    
    // MARK: - Helpers
    private func setupRandomEquation() {
        self.breakdownData = CurrencyBreakdownFactory.getRandomBreakdown()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isAnimating = true
        }
    }
    
    private func getAnimation(delay: Double) -> Animation {
        .easeInOut(duration: animDuration)
        .repeatForever(autoreverses: true)
        .delay(delay)
    }
}

#Preview {
    ZStack {
        Color.blue
        MoneyLoadingAnimationView()
    }
}
