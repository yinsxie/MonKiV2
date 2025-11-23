//
//  MasterPlayView.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import SwiftUI

struct PlayViewContainer: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State private var playVM = PlayViewModel()
    @State private var inactivityManager = InactivityManager()
    
    // Store views here
    private var pages: [AnyView] {
        [
            AnyView(ATMView()),
            AnyView(ShelfView()),
            AnyView(CashierView()),
            AnyView(Color.clear),
//            AnyView(IngredientInputView()),
            AnyView(CreateDishView())
        ]
    }
    
    // MARK: - Main Body
    var body: some View {
        ZStack(alignment: .bottom) {
            PlayBackgroundView()
            
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
            including: playVM.currentPageIndex == 1 ? .all : .subviews
        )
        .onChange(of: playVM.currentPageIndex, initial: true) { _, newIndex in
            let pagesWithIdleTutorial = [1]
            if let index = newIndex, pagesWithIdleTutorial.contains(index) {
                inactivityManager.startMonitoring()
            } else {
                inactivityManager.stopMonitoring()
            }
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
    }
}

// MARK: - Subviews & Components
extension PlayViewContainer {
    
    private var pagingScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(pages.indices, id: \.self) { index in
                        pages[index]
                            .containerRelativeFrame(
                                .horizontal, count: 1, spacing: 0,
                                alignment: index == 2 ? .leading : .center)
                            .ignoresSafeArea()
                            .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            
            .scrollPosition(id: $playVM.currentPageIndex)
            .scrollBounceBehavior(.basedOnSize)
            .contentMargins(0, for: .scrollContent)
            .scrollTargetBehavior(.paging)
            .scrollDisabled(playVM.dragManager.isDragging || playVM.atmVM.isZoomed || playVM.cashierVM.isReturnedMoneyPrompted)
            .scrollIndicators(.hidden)
            .onChange(of: playVM.currentPageIndex) { _, newIndex in
                handlePageChange(newIndex)
            }
            .onAppear {
                playVM.currentPageIndex = pages.count-1
                // Force jump to CreateDishView on load
                DispatchQueue.main.async {
                    proxy.scrollTo(pages.count-1, anchor: .center)
                }
            }
            .onChange(of: playVM.currentPageIndex) { _, newVal in
                // If user interacts manually, hide the button
                if newVal != pages.count-1 {
                    playVM.isIntroButtonVisible = false
                }
            }
            .scrollTargetLayout()
        }
        
        .scrollPosition(id: $playVM.currentPageIndex)
        .scrollBounceBehavior(.basedOnSize)
        .contentMargins(0, for: .scrollContent)
        .scrollTargetBehavior(.paging)
        .scrollDisabled(playVM.dragManager.isDragging
            || playVM.atmVM.isZoomed
            || playVM.cashierVM.isReturnedMoneyPrompted
                        || playVM.cashierVM.isPlayerStopScrollingWhileReceivedMoney
        )
        .scrollIndicators(.hidden)
        .onChange(of: playVM.currentPageIndex) { _, newIndex in
            handlePageChange(newIndex)
        }
    }
    
    @ViewBuilder
    private var homeButtonOverlay: some View {
        if !playVM.atmVM.isZoomed {
            VStack {
                HStack {
                    HoldButton(type: .home, size: 122, strokeWidth: 10, onComplete: {
                        appCoordinator.popToRoot()
                    })
                    .padding(.leading, 48)
                    .padding(.top, 48)
                    
                    Spacer()
                }
                Spacer()
            }
            //            .ignoresSafeArea(.all)
        }
    }
    
    @ViewBuilder
    private var gameControlLayer: some View {
        // Wallet View
        GeometryReader { _ in
            Color.clear
        }
        .overlay(alignment: .bottomTrailing) {
            let currentIndex = playVM.currentPageIndex ?? 0
            WalletView()
                .padding(.trailing, 30)
                .offset(y: playVM.walletVM.isWalletOpen ? 0 : 125)
                .padding(.bottom, playVM.walletVM.isWalletOpen ? -125 : 0)
                .background(GeometryReader { geo in
                    Color.clear.preference(key: ViewFrameKey.self, value: ["WALLET": geo.frame(in: .named("GameSpace"))])
                })
                .opacity((currentIndex < 4 && !playVM.atmVM.isZoomed) ? 1 : 0)
            
        }
        .overlay(alignment: .trailing) {
            let currentIndex = playVM.currentPageIndex ?? 0
            
            ShoppingBagSideBarView()
                .opacity(currentIndex == pages.count-1 ? 1 : 0)
                .disabled(currentIndex != pages.count-1)
        }
        .overlay {
            ZStack {
                if playVM.dishVM.isStartCookingTapped {
                    Color.black.opacity(0.4)
                    DishImageView()
                }
            }
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .zIndex(5)
        }
        .overlay {
            ZStack {
                if playVM.cashierVM.isReturnedMoneyPrompted {
                    Color.black
                        .opacity(0.4)
                        .ignoresSafeArea()
                    
                    CashierMonkiView()
                        .offset(x: 225, y: -68)
                        .onTapGesture {
                            playVM.cashierVM.onReturnedMoneyTapped()
                        }
                }
            }
            
        }
        // this needs to be here so that cart animations happen behind cart
        AnimationOverlayView()
        
        // Cart View
        let currentIndex = playVM.currentPageIndex ?? 0
        let cartVisibleIndices = [1, 2]
        
        CartView()
            .offset(y: 160)
            .opacity(cartVisibleIndices.contains(currentIndex) ? 1 : 0)
    }
    
    @ViewBuilder
    private var visualEffectsLayer: some View {
        DragOverlayView()
        
        if playVM.isFlyingMoney, let currency = playVM.flyingMoneyCurrency {
            FlyingMoneyAnimationView(
                currency: currency,
                startPoint: CGPoint(x: playVM.atmFrame.midX, y: playVM.atmFrame.midY + 120),
                endPoint: CGPoint(x: playVM.walletFrame.midX, y: playVM.walletFrame.midY + 180)
            )
        }
    }
    
    @ViewBuilder
    private var topPageControl: some View {
        VStack {
            PageControl(
                currentPageIndex: $playVM.currentPageIndex,
                pageCount: pages.count
            )
            
            Spacer()
        }
        .padding(.top, 16)
        .allowsHitTesting(!playVM.atmVM.isZoomed && !playVM.dishVM.isStartCookingTapped)
        .opacity((playVM.atmVM.isZoomed || playVM.dishVM.isStartCookingTapped) ? 0 : 1)
    }
    
    private func isCurrentPage(_ index: Int) -> Bool {
        return (playVM.currentPageIndex ?? 0) == index
    }
}

// MARK: - Helper Logic functions
extension PlayViewContainer {
    
    private func handlePageChange(_ newIndex: Int?) {
        guard playVM.atmVM.isZoomed else { return }
        
        if newIndex != 0 {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                playVM.atmVM.isZoomed = false
            }
        }
    }
    
    private func handleFrameUpdates(_ frames: [String: CGRect]) {
        DispatchQueue.main.async {
            if let atm = frames["ATM"], self.playVM.atmFrame != atm {
                self.playVM.atmFrame = atm
            }
            if let wallet = frames["WALLET"], self.playVM.walletFrame != wallet {
                self.playVM.walletFrame = wallet
            }
        }
    }
}

#Preview {
    PlayViewContainer()
        .environmentObject(AppCoordinator())
}
