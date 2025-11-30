//
//  MultiPlayerModeView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 29/11/25.
//

import SwiftUI

struct MultiPlayerModeView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var matchManager: MatchManager
    
    var onOnlineModeSelected: (() -> Void)?
    var onFriendModeSelected: (() -> Void)?
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(edges: .all)
            
            VStack {
                headerSection
                Spacer()
            }
            
            contentSection
        }
    }
}

// MARK: - Subviews & Components
extension MultiPlayerModeView {
    private var headerSection: some View {
        HStack {
            ReturnButton(action: {
                appCoordinator.popLast()
            })
            .accessibilityLabel("Kembali ke halaman sebelumnya")
            .padding(.leading, 48)
            .padding(.top, 48)
            
            Spacer()
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .center, spacing: 72) {
            Text("Pilih mode bermain")
                .font(.fredokaSemiBold(size: 48))
                .foregroundStyle(ColorPalette.playWithFriendTitle)
            
            HStack(spacing: 32) {
                GameModeCard(
                    backgroundImage: "Online_Mode_Background",
                    buttonText: "Bikin ruang main",
                    iconName: "icon_multi_create_room",
                    action: {
                        onOnlineModeSelected?()
                    }
                )
                
                GameModeCard(
                    backgroundImage: "Friend_Mode_Background",
                    buttonText: "Main Bareng",
                    iconName: "icon_multi_join_room",
                    action: {
                        onFriendModeSelected?()
                    }
                )
            }
        }
        .offset(y: 25)
    }
}

struct GameModeCard: View {
    let backgroundImage: String
    let buttonText: String
    let iconName: String
    let action: () -> Void
    
    var body: some View {
        ZStack {
            Image(backgroundImage)
                .resizable()
                .scaledToFit()
                .frame(width: 600)
            
            MultiStateButton(
                text: buttonText,
                iconName: iconName,
                state: .active,
                action: action
            )
            .offset(y: 165)
        }
    }
}

// MARK: - Preview
struct MultiPlayerModeView_Previews: PreviewProvider {
    static var previews: some View {
        MultiPlayerModeView()
            .environmentObject(AppCoordinator())
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
