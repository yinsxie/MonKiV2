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
    
    // Store views here
    private var pages: [AnyView] {
        [
            AnyView(ATMView()),
            AnyView(ShelfView()),
            AnyView(CashierView()),
            AnyView(Color.clear),
            AnyView(IngredientInputView()),
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
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(pages.indices, id: \.self) { index in
                    pages[index]
                        .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
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
        .scrollDisabled(playVM.dragManager.isDragging || playVM.atmVM.isZoomed)
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
                    Button(action: {
                        AudioManager.shared.play(.buttonClick)
                        appCoordinator.popToRoot()
                    }, label: {
                        Image("home_button")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 112, height: 112)
                    })
                    .padding(.leading, 80)
                    .padding(.top, 80)
                    
                    Spacer()
                }
                Spacer()
            }
            .ignoresSafeArea(.all)
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
                .opacity(currentIndex == 5 ? 1 : 0)
                .disabled(currentIndex != 5)
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
                GeometryReader { geo in
                    let totalWidth = geo.size.width
                    
                    HStack(spacing: 0) {
                        ForEach(pages.indices, id: \.self) { index in
                            Circle()
                                .fill(isCurrentPage(index) ? Color.white : Color.white.opacity(0.4))
                                .frame(width: 10, height: 10)
                                .scaleEffect(isCurrentPage(index) ? 1.2 : 1.0)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(height: geo.size.height)
                    
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let locationX = value.location.x
                                let itemWidth = totalWidth / CGFloat(pages.count)
                                let newIndex = Int(locationX / itemWidth)
                                
                                if newIndex >= 0 && newIndex < pages.count {
                                    if playVM.currentPageIndex != newIndex {
                                        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
                                            playVM.currentPageIndex = newIndex
                                        }
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    }
                                }
                            }
                    )
                }
                .frame(width: 200, height: 40)
                .background(.ultraThinMaterial, in: Capsule())
                Spacer()
            }
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
