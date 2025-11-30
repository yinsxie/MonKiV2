//
//  MatchFriendView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 29/11/25.
//

import SwiftUI

struct MatchFriendView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
   
    var onBackButtonPressed: (() -> Void)?
    var onHostButtonPressed: (() -> Void)?
    var onJoinButtonPressed: (() -> Void)?
    
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
                .offset(y: 25)
        }
    }
}

// MARK: - View Sections
extension MatchFriendView {
    private var headerSection: some View {
        HStack {
            ReturnButton {
                onBackButtonPressed?()
            }
//            HoldButton(type: .close, size: 122, strokeWidth: 10, onComplete: {
//                onBackButtonPressed?()
//            })
            .accessibilityLabel("Kembali ke halaman sebelumnya")
            .padding(.leading, 48)
            .padding(.top, 48)
            
            Spacer()
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .center, spacing: 40) {
            Text("Aku mau...")
                .font(.fredokaSemiBold(size: 48))
                .foregroundStyle(ColorPalette.playWithFriendTitle)
            
            HStack(spacing: 32) {
                MatchOptionCard(
                    characterImage: "monki_multi_full_active_player2",
                    buttonText: "Bikin ruang main",
                    iconName: "icon_multi_create_room",
                    action: {
                        //Host
                        onHostButtonPressed?()
                    }
                )
                
                MatchOptionCard(
                    characterImage: "monki_multi_full_active_player1_1",
                    buttonText: "Gabung aja",
                    iconName: "icon_multi_join_room",
                    action: {
                        // Join
                        onJoinButtonPressed?()
                    }
                )
            }
        }
    }
}

// MARK: - Reusable Component
struct MatchOptionCard: View {
    let characterImage: String
    let buttonText: String
    let iconName: String
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Image(characterImage)
                .resizable()
                .scaledToFit()
                .frame(width: 354)
            
            MultiStateButton(
                text: buttonText,
                iconName: iconName,
                state: .active,
                action: action
            )
        }
    }
}

// MARK: - Preview
struct MatchFriendView_Previews: PreviewProvider {
    static var previews: some View {
        MatchFriendView()
            .environmentObject(AppCoordinator())
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
