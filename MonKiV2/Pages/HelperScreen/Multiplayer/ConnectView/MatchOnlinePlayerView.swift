//
//  MatchOnlinePlayerView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 29/11/25.
//

import SwiftUI

struct MatchOnlinePlayerView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @ObservedObject var matchManager: MatchManager
    
    var onCancelMatchMakingPressed: (() -> Void)?
    var onReadyPressed: (() -> Void)?
    @State var isReady = false
    
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
            
            VStack(alignment: .center, spacing: 40) {
                matchContentSection
                actionButtonSection
                    .opacity(!isReady ? 1 : 0)
            }
            .offset(y: 25)
        }
        .onChange(of: matchManager.isOtherPlayerConnected) { _, newValue in
            if newValue {
                AudioManager.shared.play(.changeSound)
            }
        }
    }
}

// MARK: - Main Sections
extension MatchOnlinePlayerView {
    
    private var headerSection: some View {
        HStack {
            HoldButton(type: .close, size: 122, strokeWidth: 10, onComplete: {
                onCancelMatchMakingPressed?()
            })
            .accessibilityLabel("Kembali ke halaman sebelumnya")
            .padding(.leading, 48)
            .padding(.top, 48)
            Spacer()
        }
    }
    
    private var matchContentSection: some View {
        HStack(spacing: 32) {
            // MARK: - Remote Player (Friend)
            PlayerColumnView(
                characterImage: matchManager.isOtherPlayerConnected ? "monki_multi_full_active_player2" : "monki_multi_full_disable_1",
                sparkContent: {
                    Image("spark")
                        .resizable()
                        .scaledToFit()
                        .opacity(matchManager.isOtherPlayerConnected ? 1.0 : 0.0)
                }
            ) {
                remotePlayerProfile
            }
            
            // MARK: - Local Player (Me)
            PlayerColumnView(
                characterImage: matchManager.isOtherPlayerConnected ? "monki_multi_full_active_player1_3" : "monki_multi_full_active_player1_2"
            ) {
                localPlayerProfile
            }
        }
    }
    
    private var actionButtonSection: some View {
        MultiStateButton(
            text: matchManager.isOtherPlayerConnected ? "Siap main!" : "Mencari Pemain",
            iconName: matchManager.isOtherPlayerConnected ? nil : "icon_loading_white",
            state: matchManager.isOtherPlayerConnected ? .active : .loading,
            action: {
                onReadyPressed?()
                isReady = true
            }
        )
    }
}

// MARK: - Profile Logic Builders
extension MatchOnlinePlayerView {
    @ViewBuilder
    private var remotePlayerProfile: some View {
        HStack(spacing: 10) {
            if let avatar = matchManager.otherPlayerAvatar {
                avatar
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 64, height: 64)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // TODO: perlu validasi/kondisi kalau misalnya temennya masih dicari
                if !matchManager.isOtherPlayerConnected {
                    Text("Mencari...")
                        .font(.fredokaSemiBold(size: 24))
                        .foregroundStyle(ColorPalette.neutral700)
                } else {
                    Text(matchManager.otherPlayerName)
                        .font(.fredokaSemiBold(size: 24))
                        .lineLimit(1)
                        .foregroundStyle(ColorPalette.playerName)
                    
                    if matchManager.isRemotePlayerReady {
                        StatusBadge(text: "Siap", color: ColorPalette.greenMoney)
                    } else {
                        HStack(spacing: 4) {
                            Image("icon_loading_grey")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .rotating(duration: 2)
                            
                            Text(matchManager.isOtherPlayerConnected ? "Menunggu..." : "Menghubungkan")
                                .font(.fredokaMedium(size: 12))
                                .foregroundColor(ColorPalette.connectPlayerName)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var localPlayerProfile: some View {
        HStack(spacing: 10) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 64, height: 64)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Kamu")
                    .font(.fredokaSemiBold(size: 24))
                    .foregroundStyle(ColorPalette.playerName)
                
                if matchManager.isLocalPlayerReady {
                    StatusBadge(text: "Siap", color: ColorPalette.greenMoney)
                }
            }
        }
    }
}

// MARK: - Reusable Components
struct PlayerColumnView<ProfileContent: View, SparkContent: View>: View {
    let characterImage: String
    @ViewBuilder var sparkContent: SparkContent
    @ViewBuilder var profileContent: ProfileContent
    
    init(characterImage: String, @ViewBuilder sparkContent: () -> SparkContent, @ViewBuilder profileContent: () -> ProfileContent) {
        self.characterImage = characterImage
        self.sparkContent = sparkContent()
        self.profileContent = profileContent()
    }
    
    init(characterImage: String, @ViewBuilder profileContent: () -> ProfileContent) where SparkContent == EmptyView {
        self.characterImage = characterImage
        self.sparkContent = EmptyView()
        self.profileContent = profileContent()
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            profileContent
                .padding(4)
                .padding(.trailing, 20)
                .background(
                    Capsule()
                        .fill(Color.white)
                )
            
            ZStack {
                Image(characterImage)
                    .resizable()
                    .scaledToFit()
                
                sparkContent
            }
            .frame(width: 354)
        }
    }
}

struct StatusBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.fredokaMedium(size: 12))
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(color)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

// MARK: - Previews
//struct MatchOnlinePlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        MatchOnlinePlayerView()
//            .environmentObject(AppCoordinator())
//            .previewInterfaceOrientation(.landscapeLeft)
//    }
//}
