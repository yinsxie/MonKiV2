//
//  MatchOnlinePlayerView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 29/11/25.
//

import SwiftUI

struct MatchOnlinePlayerView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @StateObject var matchManager = MatchManager()
    
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
            }
            .offset(y: 25)
        }
    }
}

// MARK: - Main Sections
extension MatchOnlinePlayerView {
    
    private var headerSection: some View {
        HStack {
            HoldButton(type: .close, size: 122, strokeWidth: 10, onComplete: {
                appCoordinator.popLast()
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
                characterImage: "monki_multi_full_disable_1", // TODO: kalau playernya nemu ganti asset ke "monki_multi_full_active_player2"
                sparkContent: {
                    // TODO: ini pakein validasi if kondisi player onlinenya dah nemu baru masukkin sparknya
                    Image("spark")
                        .resizable()
                        .scaledToFit()
                }
            ) {
                remotePlayerProfile
            }
            
            // MARK: - Local Player (Me)
            PlayerColumnView(
                characterImage: "monki_multi_full_active_player1_2", // TODO: if online player found, change asset to "monki_multi_full_active_player1_3"
            ) {
                localPlayerProfile
            }
        }
    }
    
    private var actionButtonSection: some View {
        // TODO: ntar kasih kondisi kalau player found, bikin statenya .active, textnya "Siap main!"
        MultiStateButton(
            text: "Mencari Pemain",
            iconName: "icon_loading_white",
            state: .loading,
            action: { }
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
                Image(systemName: "person.crop.circle.badge.questionmark")
                    .resizable()
                    .frame(width: 64, height: 64)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // TODO: perlu validasi/kondisi kalau misalnya temennya masih dicari
                // jadinya yg dimunculin cuman..
                // Text("Mencari...")
                //    .font(.fredokaSemiBold(size: 24))
                //    .foregroundStyle(ColorPalette.neutral700)
                
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
                        
                        Text("Menghubungkan")
                            .font(.fredokaMedium(size: 12))
                            .foregroundColor(ColorPalette.connectPlayerName)
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
struct MatchOnlinePlayerView_Previews: PreviewProvider {
    static var previews: some View {
        MatchOnlinePlayerView()
            .environmentObject(AppCoordinator())
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
