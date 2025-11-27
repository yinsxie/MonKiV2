//
//  FloatingPriceFeedback.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 19/11/25.
//

import SwiftUI

struct FloatingPriceTextData: Identifiable, Equatable {
    let id = UUID()
    let value: Int
}

struct FloatingPriceTextView: View {
    let data: FloatingPriceTextData
    let onAnimationEnd: (UUID) -> Void
    
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        Text(data.value > 0 ? "+\(data.value)" : "\(data.value)")
            .font(.VT323(size: 52))
            .foregroundStyle(Color(hex: "3D3D3D"))
            .offset(y: offset)
            .opacity(opacity)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    offset = -50
                    opacity = 0.5
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    onAnimationEnd(data.id)
                }
            }
    }
}
