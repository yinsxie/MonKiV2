//
//  MoneyBreakView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 30/11/25.
//

import SwiftUI

struct MoneyBreakView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State var viewModel: MoneyBreakViewModel
    
    var body: some View {
        GeometryReader { fullGeo in
            ZStack {
                Image("background_multi_share_budget")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    ZStack(alignment: .top) {
                        Image("money_break")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 1118, height: 171)
                            .background(GeometryReader { geo in
                                Color.clear.onAppear {
                                    viewModel.breakerFrame = geo.frame(in: .named("BudgetSpace"))
                                }
                                .onChange(of: geo.frame(in: .named("BudgetSpace"))) { _, newFrame in
                                    viewModel.breakerFrame = newFrame
                                }                            })
                            .offset(y: 130)
                        
                        //TODO: maapkeun blm saya implement animasi tangannya masuk
                        Image("monki_hand")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 644)
                            .rotationEffect(.degrees(180))
                    }
                    
                    Spacer()
                }
                .ignoresSafeArea(edges: .top)
                .offset(y: -100)
                
                VStack {
                    Spacer()
                    HStack {
                        // MARK: - Host Zone (Kiri)
                        ZStack {
                            Image("share_budget_area_2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 444)
                            
                            // Component Profile + Wallet
                            PlayerStatsView(
                                playerName: viewModel.amIHost ? viewModel.localPlayerName : viewModel.remotePlayerName,
                                amount: viewModel.hostTotal,
                                isReady: viewModel.amIHost ? viewModel.isLocalReady : viewModel.isRemoteReady,
                                isGuest: false,
                                amIHost: !viewModel.amIHost
                            )
                            .offset(x: 70, y: 80)
                        }
                        .offset(x: -50)
                        .background(GeometryReader { geo in
                            Color.clear.onAppear {
                                viewModel.hostZoneFrame = geo.frame(in: .named("BudgetSpace"))
                            }
                        })
                        
                        MultiStateButton(
                            text: viewModel.actionButtonText,
                            state: viewModel.actionButtonState,
                            action: {
                                viewModel.onButtonTapped()
                            }
                        )
                        .offset(y: -50)
                        
                        ZStack {
                            Image("share_budget_area_1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 444)
                            
                            // TODO: ganti ke username temen
                            PlayerStatsView(
                                playerName: !viewModel.amIHost ? viewModel.localPlayerName : viewModel.remotePlayerName,
                                amount: viewModel.guestTotal,
                                isReady: !viewModel.amIHost ? viewModel.isLocalReady : viewModel.isRemoteReady,
                                isGuest: true,
                                amIHost: viewModel.amIHost
                            )
                            .offset(x: -70, y: 80)
                        }
                        .offset(x: 50)
                        .background(GeometryReader { geo in
                            Color.clear.onAppear {
                                viewModel.guestZoneFrame = geo.frame(in: .named("BudgetSpace"))
                            }
                        })
                    }
                    .offset(y: 100)
                }
                .ignoresSafeArea(edges: .bottom)
                
                moneyLayer(geo: fullGeo)
            }
            .coordinateSpace(name: "BudgetSpace")
            .onAppear {
                viewModel.totalContainerSize = fullGeo.size
                viewModel.checkForHostStatus()
            }
        }
        .clipped()
    }
    
    // MARK: - Logic Money Layer
    private func moneyLayer(geo: GeometryProxy) -> some View {
        ForEach(viewModel.sharedMoneys) { money in
            Image(money.currency.imageAssetPath)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 50)
                .rotationEffect(.degrees(money.rotation))
                .scaleEffect(money.isBeingDragged ? 1.2 : 1.0)
                .opacity(shouldDim(money) ? 0.6 : 1.0)
                .overlay(borderOverlay(for: money))
                .position(
                    x: money.position.x * geo.size.width,
                    y: money.position.y * geo.size.height
                )
                .gesture(dragGesture(for: money, geo: geo))
        }
    }
    
    private func borderOverlay(for money: SharedMoney) -> some View {
        RoundedRectangle(cornerRadius: 5)
            .stroke(
                money.owner == .host ? ColorPalette.playerName :
                    money.owner == .guest ? Color.black : Color.clear,
                lineWidth: 3
            )
            .rotationEffect(.degrees(money.rotation))
    }
    
    private func shouldDim(_ money: SharedMoney) -> Bool {
        guard let locker = money.lockedBy else { return false }
        return locker != viewModel.myRole
    }
    
    private func dragGesture(for money: SharedMoney, geo: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if !canDrag(money) { return }
                
                if money.lockedBy == nil {
                    viewModel.onDragStart(id: money.id)
                }
                viewModel.onDragChanged(id: money.id, location: value.location)
            }
            .onEnded { value in
                if !canDrag(money) { return }
                viewModel.onDragEnded(id: money.id, location: value.location)
            }
    }
    
    private func canDrag(_ money: SharedMoney) -> Bool {
        if viewModel.isLocalReady { return false }
        if let locker = money.lockedBy, locker != viewModel.myRole { return false }
        
        if viewModel.amIHost {
            return money.owner != .guest
        } else {
            return money.owner != .host
        }
    }
}

// MARK: - Reusable Component (Tidak Berubah)
struct PlayerStatsView: View {
    
    @Environment(PlayViewModel.self) var playVM
    @ObservedObject var gcManager = GameCenterManager.shared
    
    let playerName: String
    let amount: Int
    let isReady: Bool
    let isGuest: Bool
    let amIHost: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            if isGuest {
                profileContent
                walletContent
            } else {
                walletContent
                profileContent
            }
        }
    }
    
    // Bagian Wallet (Dompet & Koin)
    @ViewBuilder
    var walletContent: some View {
        ZStack(alignment: .bottom) {
            Image("Wallet")
                .resizable()
                .scaledToFit()
                .frame(width: 292)
            
            HStack(spacing: 11) {
                Image("coin")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 40)
                
                Text("\(amount)")
                    .font(.fredokaMedium(size: 36, relativeTo: .title))
            }
            .padding(.vertical)
            .padding(.horizontal, 25)
            .background(
                RoundedRectangle(cornerRadius: 60)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 60)
                    .stroke(ColorPalette.neutral300, lineWidth: 6.22)
            )
            .offset(y: -185)
        }
    }
    
    // Bagian Profile (Avatar, Nama, Status)
    @ViewBuilder
    var profileContent: some View {
        
        HStack(spacing: 10) {
            if amIHost, let profile = playVM.matchManager?.otherPlayerAvatarUIImage {
                Image(uiImage: profile)
                    .resizable()
                    .frame(width: 64, height: 64)
            } else if !amIHost, let profile = gcManager.currentPlayerAvatar {
                profile
                    .resizable()
                    .frame(width: 64, height: 64)
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 64, height: 64)
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(playerName)
                    .font(.fredokaSemiBold(size: 24))
                    .foregroundStyle(ColorPalette.playerName)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .layoutPriority(1)
                
                if isReady {
                    Text("Siap")
                        .font(.fredokaMedium(size: 12))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(ColorPalette.greenMoney)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
        }
        .padding(4)
        .padding(.trailing, 20)
        .background(
            Capsule()
                .fill(Color.white)
        )
        .frame(maxWidth: 250, alignment: .leading)
        .offset(y: -20)
    }
}

#if DEBUG
struct MoneyBreakView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MoneyBreakView(viewModel: createPreviewViewModel(isHost: true))
                .previewDisplayName("View as Host")
                .previewInterfaceOrientation(.landscapeLeft)
            
            MoneyBreakView(viewModel: createPreviewViewModel(isHost: false))
                .previewDisplayName("View as Guest")
                .previewInterfaceOrientation(.landscapeLeft)
        }
        .environmentObject(AppCoordinator())
    }
    
    static func createPreviewViewModel(isHost: Bool) ->
    MoneyBreakViewModel {
        // Mock Parent (PlayViewModel)
        let parentVM = PlayViewModel(gameMode: .multiplayer)
        let vm = MoneyBreakViewModel(parent: parentVM)
        
        vm.amIHost = isHost
        vm.localPlayerName = isHost ? "Yonathan" : "Aretha"
        vm.remotePlayerName = isHost ? "Aretha" : "Yonathan"
        vm.isLocalReady = false
        vm.isRemoteReady = true
        
        vm.sharedMoneys = [
            SharedMoney(id: UUID(), currency: .idr100, position: CGPoint(x: 0.5, y: 0.4), owner: nil, lockedBy: nil),
            SharedMoney(id: UUID(), currency: .idr20, position: CGPoint(x: 0.2, y: 0.7), owner: .host, lockedBy: nil),
            SharedMoney(id: UUID(), currency: .idr20, position: CGPoint(x: 0.8, y: 0.7), owner: .guest, lockedBy: nil)
        ]
        
        return vm
    }
}
#endif
