//
//  NotificationView.swift
//  MonKiV2
//
//  Created by William on 30/11/25.
//

import SwiftUI

enum NotificationType {
    case remotePlayerReadyToCook
}

struct NotificationView: View {
    @Environment(PlayViewModel.self) var playVM
    let type: NotificationType
    @State private var dragOffset: CGFloat = 0
    private var prefixImage: UIImage? {
        switch type {
        case .remotePlayerReadyToCook:
            playVM.matchManager?.otherPlayerAvatarUIImage
        }
    }
    
    private var message: String {
        switch type {
        case .remotePlayerReadyToCook:
            let name = playVM.matchManager?.otherPlayerName ?? "Remote Player"
            return "\(name) is ready to cook!"
        }
    }
    
    var body: some View {
        HStack(spacing: 10) {
            if let img = prefixImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            } else {
                Circle()
                    .frame(width: 50, height: 50)
            }
            
            Text(message)
                .font(.fredokaMedium(size: 20))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(ColorPalette.neutral50.opacity(0.9))
        )
        .transition(.move(edge: .top).combined(with: .opacity))
        .gesture(
            DragGesture(minimumDistance: 10)
                .onChanged { value in
                    // Allow dragging upwards and update the offset
                    if value.translation.height < 0 {
                        dragOffset = value.translation.height
                    }
                }
                .onEnded { value in
                    // If dragged up significantly, dismiss the notification
                    if value.translation.height < -20 {
                        playVM.userDismiss()
                    }
                    // Reset the offset after the gesture ends
                    dragOffset = 0
                }
        )
        .offset(y: dragOffset)
        .animation(.spring(), value: dragOffset)
    }
}

#Preview {
    PlayViewContainer(forGameMode: .singleplayer, chef: .bread)
        .environmentObject(AppCoordinator())
}
