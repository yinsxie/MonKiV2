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
            
            WalletView()
                .padding(.trailing, 30)
                .offset(y: playVM.walletVM.isWalletOpen ? 0 : 125)
                .padding(.bottom, playVM.walletVM.isWalletOpen ? -125 : 0)
                .background(GeometryReader { geo in
                    Color.clear.preference(key: ViewFrameKey.self, value: ["WALLET": geo.frame(in: .named("GameSpace"))])
                })
                .opacity(currentIndex < playVM.getPageIndex(for: .createDish) && !playVM.atmVM.isZoomed ? 1 : 0)
        }
        
        // Shopping Bag Side Bar View
        .overlay(alignment: .trailing) {
            let currentIndex = playVM.currentPageIndex ?? 0
            
            ShoppingBagSideBarView()
                .opacity(playVM.getPage(at: currentIndex) == .createDish ? 1 : 0)
                .disabled(playVM.getPage(at: currentIndex) != .createDish)
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
                        
                        CashierMonkiView()
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
        
        CartView()
            .offset(y: 160)
            .opacity(cartVisibleIndices.contains(currentPage) ? 1 : 0)
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
        let isPageControlAllowHitTesting = !playVM.atmVM.isZoomed && !playVM.dishVM.isStartCookingTapped && !playVM.cashierVM.isReturnedMoneyPrompted
        let isPageControlVisible = playVM.atmVM.isZoomed || playVM.dishVM.isStartCookingTapped || playVM.cashierVM.isReturnedMoneyPrompted
        
        VStack {
            PageControl(
                currentPageIndex: $playVM.currentPageIndex,
                pageCount: pages.count
            )
            
            Spacer()
        }
        .padding(.top, 16)
        .allowsHitTesting(isPageControlAllowHitTesting)
        .opacity(isPageControlVisible ? 0 : 1)
    }
}
