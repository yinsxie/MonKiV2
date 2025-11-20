//
//  FlyingMoneyView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 18/11/25.
//

import SwiftUI

struct FlyingMoneyAnimationView: View {
    let currency: Currency
    let startPoint: CGPoint
    let endPoint: CGPoint
    
    @State private var progress: CGFloat = 0.0
    
    var body: some View {
        MoneyView(money: Money(forCurrency: currency), isMoreThanOne: false, isBeingDragged: true)
            .scaleEffect(progress == 0 ? 0.5 : 0.3)
            .position(x: startPoint.x + (endPoint.x - startPoint.x) * progress,
                      y: startPoint.y + (endPoint.y - startPoint.y) * progress)
            .opacity(progress > 0.9 ? 0 : 1)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8)) {
                    progress = 1.0
                }
            }
    }
}
