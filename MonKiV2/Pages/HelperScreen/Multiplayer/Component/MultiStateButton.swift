//
//  MultiStateButton.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 29/11/25.
//

import SwiftUI

struct MultiStateButton: View {
    
    enum ButtonState {
        case active
        case disabled
        case loading
    }
    
    var text: String
    var iconName: String?
    
    var state: ButtonState
    
    var action: () -> Void
    
    private var backgroundImageName: String {
        switch state {
        case .active:
            return "button_multi_active"
        case .disabled:
            return "button_multi_disable"
        case .loading:
            return "button_multi_inactive"
        }
    }
    
    private var isLoading: Bool {
        return state == .loading
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Image(backgroundImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 421, height: 107)
            
            HStack(alignment: .center, spacing: 12) {
                Text(text)
                    .font(.fredokaSemiBold(size: 40))
                    .fixedSize(horizontal: true, vertical: false)
                
                if let icon = iconName {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                        .animation(
                            isLoading
                            ? Animation.linear(duration: 1.0).repeatForever(autoreverses: false)
                            : .default,
                            value: isLoading
                        )
                        .rotating(duration: 2, enabled: isLoading)
                }
            }
            .padding(24)
            .foregroundColor(.white)
        }
        .frame(width: 421, height: 107)
        //        .background(.red)
        .onTapGesture {
            if state == .active {
                action()
            }
        }
    }
}

// MARK: - Preview
struct MultiStateButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            
            // 1. Active
            MultiStateButton(
                text: "Main online",
                state: .active,
                action: { print("Clicked Active") }
            )
            
            // 2. Loading
            MultiStateButton(
                text: "Mencari Pemain",
                iconName: "icon_loading_white",
                state: .loading,
                action: { print("Ga bisa diklik") }
            )
            
            // 3. Disabled
            MultiStateButton(
                text: "Locked",
                state: .disabled,
                action: { print("Ga bisa diklik") }
            )
        }
        .padding()
        .background(Color.gray)
        .previewLayout(.sizeThatFits)
    }
}
