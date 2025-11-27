//
//  HoldButton.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 21/11/25.
//

import SwiftUI

enum HoldButtonType {
    case home
    case remove
    
    var imageName: String {
        switch self {
        case .home:
            return "home_button"
        case .remove:
            return "removeButton"
        }
    }
}

struct HoldButton: View {
    var type: HoldButtonType
    
    var size: CGFloat
    var strokeWidth: CGFloat
    var holdDuration: TimeInterval = 1.0
    
    var onComplete: () -> Void
    
    @State private var isHolding = false
    @State private var progress: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            Image(type.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
            
            if isHolding {

                Circle()
                    .stroke(Color.white, lineWidth: strokeWidth)
                    .frame(width: size - strokeWidth, height: size - strokeWidth)
            }

            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(ColorPalette.buttonOnHold, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .frame(width: size - strokeWidth, height: size - strokeWidth)
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
        .onLongPressGesture(minimumDuration: holdDuration, maximumDistance: 50) { isPressing in
            if isPressing {
                isHolding = true
                withAnimation(.linear(duration: holdDuration)) {
                    progress = 1.0
                }
            } else {
                isHolding = false
                withAnimation(.easeOut(duration: 0.2)) {
                    progress = 0.0
                }
            }
        } perform: {
            AudioManager.shared.play(.buttonClick)
            onComplete()
            
            isHolding = false
            progress = 0.0
        }
    }
}

// MARK: - Preview & Contoh Penggunaan
#Preview {
    VStack(spacing: 50) {
        HoldButton(type: .home, size: 122, strokeWidth: 10, onComplete: {
            print("Home Selesai!")
        })
        
        HoldButton(type: .remove, size: 122, strokeWidth: 10, onComplete: {
            print("Remove Selesai!")
        })
    }
}
