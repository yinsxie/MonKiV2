//
//  MasterPlayView.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import SwiftUI

struct PlayViewContainer: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State var playVM: PlayViewModel
    @State var inactivityManager = InactivityManager()
    
    init(forGameMode mode: GameMode, matchManager: MatchManager? = nil, chef: ChefType? = nil) {
        _playVM = State(initialValue: PlayViewModel(gameMode: mode, matchManager: matchManager, chef: chef))
    }
    
    @ViewBuilder
    private func view(for identifier: PageIdentifier) -> some View {
        switch identifier {
        case .ATM:
            ATMView()
        case .shelfA:
            ShelfView() // Your current ShelfView
        case .shelfB:
            SecondShelfView() // Your current SecondShelfView
        case .cashierLoading:
            CashierView()
        case .cashierPayment:
            Color.clear // Your 'Color.clear' placeholder
        case .createDish:
            CreateDishView()
        case .ingredientList:
            IngredientInputView()
        }
    }
    
    var pages: [AnyView] {
        return playVM.gamePages.map { AnyView(view(for: $0)) }
    }
    
    // MARK: - Main Body
    var body: some View {
        ZStack(alignment: .bottom) {
            
            Color.white
            
            // 1. Main Scroll View
            pagingScrollView
            
            // 2. Home Button
            homeButtonOverlay
            
            // 3. Game Control (wallet and cart)
            gameControlLayer
            
            // 4. Visual Effect (Drag, Animation, Money)
            visualEffectsLayer
            
            topPageControl
        }
        // MARK: - Idle System (get items, get interaction, check for pages)
        .overlayPreferenceValue(SpotlightKey.self) { items in
            IdleSpotlightOverlay(
                isIdle: $inactivityManager.isIdle,
                items: items,
                onWakeUp: { inactivityManager.userDidInteract() }
            )
            .ignoresSafeArea()
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in inactivityManager.userDidInteract() }
                .onEnded { _ in inactivityManager.userDidInteract() },
            including: playVM.getCurrentPage() == .shelfA ? .all : .subviews
        )
        .onChange(of: inactivityManager.isIdle) { _, isIdle in
            if isIdle {
                handleOnWalletIdle()
                // MARK: Add more if there's idle interaction
            }
        }
        .onChange(of: playVM.currentPageIndex, initial: true) { _, newIndex in
            toggleInactivityMonitoring(on: newIndex)
        }
        // MARK: - Environment Injection
        .environment(playVM)
        .environment(playVM.cartVM)
        .environment(playVM.shelfVM)
        .environment(playVM.cashierVM)
        .environment(playVM.walletVM)
        .environment(playVM.dragManager)
        .environment(playVM.dishVM)
        .environment(playVM.atmVM)
        .coordinateSpace(name: "GameSpace")
        // MARK: - Preference Changes
        .onPreferenceChange(ViewFrameKey.self) { frames in
            handleFrameUpdates(frames)
        }
        .onAppear {
            playVM.connectToMatch()
        }
    }
}

#Preview {
    GameRootScaler {
        PlayViewContainer(forGameMode: .singleplayer)
            .environmentObject(AppCoordinator())
    }
}
