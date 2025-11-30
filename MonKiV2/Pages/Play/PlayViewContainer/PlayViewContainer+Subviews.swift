//
//  PlayViewContainer+Subviews.swift
//  MonKiV2
//
//  Created by William on 24/11/25.
//

import SwiftUI

// MARK: - Subviews & Components
internal extension PlayViewContainer {
    var pagingScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                ZStack(alignment: .leading) {
                    PagedBackground(
                        imageName: "background_\(playVM.gameMode == .singleplayer ? "singleplayer" : "multiplayer")",
                        pageCount: pages.count
                    )
                    
                    // Pages Content
                    HStack(spacing: 0) {
                        ForEach(pages.indices, id: \.self) { index in
                            pages[index]
                                .containerRelativeFrame(
                                    .horizontal, count: 1, spacing: 0,
                                    alignment: playVM.getPage(at: index) == .cashierLoading ? .leading : .center
                                )
                                .ignoresSafeArea()
                                .id(index)
                        }
                    }
                    .scrollTargetLayout()
                }
            }
            .scrollPosition(id: $playVM.currentPageIndex)
            .scrollTargetBehavior(.paging)
            .scrollDisabled(playVM.isScrollDisabled)
            .scrollBounceBehavior(.basedOnSize)
            .contentMargins(0, for: .scrollContent)
            .scrollIndicators(.hidden)
            .onChange(of: playVM.currentPageIndex) { _, newIndex in
                handlePageChange(newIndex)
                toggleIntroButton(index: newIndex)
            }
            .onAppear {
                handleGameOnAppear(proxy)
            }
        }
    }
    
    @ViewBuilder
    var homeButtonOverlay: some View {
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
        }
    }
    
    @ViewBuilder
    var gameControlLayer: some View {
        GeometryReader { _ in
            Color.clear
        }
        
        // Wallet View
        .overlay(alignment: .bottomTrailing) {
            let currentIndex = playVM.currentPageIndex ?? 0
            let isNotOnCreateDish = playVM.getPage(at: currentIndex) != .createDish && playVM.getPage(at: currentIndex) != .ingredientList
            let isATMNotZoomed = !playVM.atmVM.isZoomed
            
            WalletView()
                .padding(.trailing, 30)
                .offset(y: playVM.walletVM.isWalletOpen ? 0 : 125)
                .padding(.bottom, playVM.walletVM.isWalletOpen ? -125 : 0)
                .background(GeometryReader { geo in
                    Color.clear.preference(key: ViewFrameKey.self, value: ["WALLET": geo.frame(in: .named("GameSpace"))])
                })
                .opacity(isNotOnCreateDish && isATMNotZoomed ? 1 : 0)
        }
        
        // Shopping Bag Side Bar View
        .overlay(alignment: .trailing) {
            let currentIndex = playVM.currentPageIndex ?? 0
            let isOnCreateDish = playVM.getPage(at: currentIndex) == .createDish
            
            ShoppingBagSideBarView()
                .opacity(isOnCreateDish ? 1 : 0)
                .disabled(!isOnCreateDish)
        }
        
        // Dish Image Overlay
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
        
        // MonKi Cashier Overlay (Money Returned)
        .overlay {
            ZStack {
                if playVM.cashierVM.isReturnedMoneyPrompted {
                    Color.black
                        .opacity(0.4)
                        .ignoresSafeArea()
                    
                    ZStack {
                        
                        RotatingShineView()
                            .frame(width: 500)
                            .offset(x: -350, y: -100)
                        
                        CashierChangeMonkiView()
                            .onTapGesture {
                                playVM.cashierVM.onReturnedMoneyTapped()
                            }
                    }
                    .offset(x: 225, y: -68)
                }
            }
            
        }
        // this needs to be here so that cart animations happen behind cart
        AnimationOverlayView()
        
        // Cart View
        let currentIndex = playVM.currentPageIndex ?? 0
        let currentPage = playVM.getPage(at: currentIndex)
        let cartVisibleIndices: [PageIdentifier] = [.shelfA, .shelfB, .cashierLoading]
        let shouldShowCart = cartVisibleIndices.contains(currentPage)
        
        CartView()
            .offset(y: 160)
            .opacity(shouldShowCart ? 1 : 0)
    }
    
    @ViewBuilder
    var visualEffectsLayer: some View {
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
    var topPageControl: some View {
        let isPageControlAllowHitTesting = !playVM.atmVM.isZoomed && !playVM.dishVM.isStartCookingTapped && !playVM.cashierVM.isPlayerDisabledNavigatingWhileReceivedMoney && !playVM.dragManager.isDragging
        let isPageControlVisible = playVM.atmVM.isZoomed || playVM.dishVM.isStartCookingTapped || playVM.cashierVM.isReturnedMoneyPrompted
        
        VStack {
            PageControl(
                currentPageIndex: $playVM.currentPageIndex,
                pageCount: pages.count
            )
            
            Spacer()
        }
        .padding(.top, 32)
        .allowsHitTesting(isPageControlAllowHitTesting)
        .opacity(isPageControlVisible ? 0 : 1)
    }
}

struct PagedBackground: View {
    let imageName: String
    let pageCount: Int

    var body: some View {
        GeometryReader { geo in
            let pageHeight = geo.size.height

            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(
                    height: pageHeight
                )
                .offset(x: -UIScreen.main.bounds.width)
        }
    }
}

#Preview {
    GameRootScaler {
        PlayViewContainer(forGameMode: .multiplayer)
            .environmentObject(AppCoordinator())
    }
}
