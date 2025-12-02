//
//  AppCoordinatorView.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import SwiftUI

struct AppCoordinatorView: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    // MARK: - Constants
    private let transitionLayerZIndex: Double = 998
    private let loadingLayerZIndex: Double = 999
    
    var body: some View {
        ZStack {
            mainNavigationStack
            transitionOverlay
            loadingOverlay
        }
        .allowsHitTesting(!appCoordinator.isTransitioning)
        .statusBarHidden(true)
        .onAppear {
            setupAppFlow()
            endSplashView()
        }
    }
    
    // MARK: - Subviews
    private var mainNavigationStack: some View {
        NavigationStack(path: $appCoordinator.navigationPath) {
            appCoordinator.buildRoot(appCoordinator.root)
                .navigationDestination(for: RootRoute.self) { route in
                    destinationView(for: route)
                }
        }
    }
    
    private var transitionOverlay: some View {
        Group {
            if appCoordinator.isTransitioning {
                ColorPalette.infoBackground
                    .ignoresSafeArea()
                    .zIndex(transitionLayerZIndex)
                    .transition(.opacity)
            }
        }
    }
    
    private var loadingOverlay: some View {
        Group {
            if appCoordinator.shouldShowLoadingItems {
                ZStack {
                    Color.clear.ignoresSafeArea()
                    
                    // MARK: - Dynamic Loading Content
                    switch appCoordinator.activeLoadingType {
                    case .standardVegetables:
                        LoadingAnimationView(variant: .vegetables)
                            .id("veggieLoading")
                    case .baseIngredients:
                        LoadingAnimationView(variant: .base)
                            .id("baseLoading")
                    case .moneyBreakdown:
                        MoneyLoadingAnimationView()
                            .id("moneyLoading")
                    case .multiPlay:
                        MonkiLoadingView()
                        
                    }
                }
                .zIndex(loadingLayerZIndex)
                .transition(.opacity)
            }
        }
    }
    
    // MARK: - Helper Methods
    @ViewBuilder
    private func destinationView(for route: RootRoute) -> some View {
        switch route {
        case .play(let playRoute):
            playRoute.delegateView()
                .navigationBarBackButtonHidden(true)
        case .helperScreen(let helperRoute):
            helperRoute.delegateView()
                .navigationBarBackButtonHidden(true)
        default:
            EmptyView()
        }
    }
    
    private func endSplashView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            appCoordinator.changeRootAnimate(root: .helperScreen(.startingPage))
        }
    }
    
    private func setupAppFlow() {
    }
}

#Preview {
    AppCoordinatorView()
        .environmentObject(AppCoordinator())
}
