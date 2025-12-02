//
//  AppCoordinatorView.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import Combine
import SwiftUI

// MARK: - Enums & Config
struct AnimationConfig {
    static let fadeDuration: Double = 0.5
    static let springResponse: Double = 0.6
    static let springDamping: Double = 0.7
    static let loadingDuration: Double = 2.0
    static let pauseBeforeFadeOut: Double = 0.2
    
    static var itemAppearanceDelay: Double { fadeDuration }
    static var routeChangeDelay: Double { fadeDuration + 0.1 }
    static var itemDisappearanceDelay: Double { loadingDuration }
    static var backgroundDisappearanceDelay: Double { loadingDuration + fadeDuration + pauseBeforeFadeOut }
}

enum LoadingType {
    case standardVegetables
    case baseIngredients
    case moneyBreakdown
    case multiPlay
}

final class AppCoordinator: ObservableObject {
    @Published var navigationPath: [RootRoute] = []
    
    @Published var root: RootRoute = .splashScreen
    
    // MARK: - Transition State
    @Published var isTransitioning: Bool = false
    @Published var shouldShowLoadingItems: Bool = false
    @Published var activeLoadingType: LoadingType = .standardVegetables
    
    // MARK: - Root Management
    func changeRootAnimate(root: RootRoute) {
        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
                self.root = root
                self.navigationPath.removeAll()
            }
        }
    }
    
    /// Only used at app launch to set initial root without animation, don't use this elsewhere
    @ViewBuilder
    func buildRoot(_ route: RootRoute) -> some View {
        switch route {
        case .splashScreen:
            SplashScreenView()
        case .play(let playRoute):
            playRoute.delegateView()
        case .helperScreen(let helperRoute):
            helperRoute.delegateView()
        }
    }
    
    func goTo(_ route: RootRoute) {
        navigationPath.append(route)
    }
    
    func popToRoot() {
        if navigationPath.isEmpty { return }
        navigationPath.removeAll()
    }
    
    func popLast() {
        if navigationPath.isEmpty { return }
        _ = navigationPath.popLast()
    }
    
    func pop(times nTime: Int) {
        guard nTime > 0 else { return }
        let countToRemove = min(nTime, navigationPath.count)
        navigationPath.removeLast(countToRemove)
    }

    func replaceTop(with route: RootRoute) {
        guard !navigationPath.isEmpty else {
            navigationPath.append(route)
            return
        }
        navigationPath[navigationPath.count - 1] = route
    }
    
    func replaceTopAnimate(with route: RootRoute) {
        guard !navigationPath.isEmpty else {
            navigationPath.append(route)
            return
        }
        
        navigationPath.removeLast()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                self.navigationPath.append(route)
            }
        }
    }
    
    func popToFlowRoot() {
        guard navigationPath.count > 1 else { return }
        navigationPath.removeLast(navigationPath.count - 1)
    }
    
    func popToRootWithFade() {
        performBackTransition { [weak self] in
            self?.popToRoot()
        }
    }
    
    func popLastWithFade() {
        performBackTransition { [weak self] in
            self?.popLast()
        }
    }
    
    func popWithFade(times nTime: Int) {
        performBackTransition { [weak self] in
            self?.pop(times: nTime)
        }
    }
    
    func replaceTopWithFade(with route: RootRoute, loadingType: LoadingType = .moneyBreakdown) {
        self.activeLoadingType = loadingType
        
        animateTransitionState(to: true)
        
        scheduleAction(after: AnimationConfig.itemAppearanceDelay) {
            withAnimation(.spring(response: AnimationConfig.springResponse, dampingFraction: AnimationConfig.springDamping)) {
                self.shouldShowLoadingItems = true
            }
        }
        
        scheduleAction(after: AnimationConfig.routeChangeDelay) {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            
            withTransaction(transaction) {
                if self.navigationPath.isEmpty {
                    self.navigationPath.append(route)
                } else {
                    //                        self.navigationPath.removeLast()
                    //                        self.navigationPath.append(route)
                    self.navigationPath[self.navigationPath.count - 1] = route
                }
            }
        }
        
        scheduleAction(after: AnimationConfig.itemDisappearanceDelay) {
            withAnimation(.easeInOut(duration: AnimationConfig.fadeDuration)) {
                self.shouldShowLoadingItems = false
            }
        }
        
        scheduleAction(after: AnimationConfig.backgroundDisappearanceDelay) {
            self.animateTransitionState(to: false, duration: 0.8)
        }
    }
    
    func navigateWithFade(_ route: RootRoute, loadingType: LoadingType = .standardVegetables) {
        self.activeLoadingType = loadingType
        
        animateTransitionState(to: true)
        
        scheduleAction(after: AnimationConfig.itemAppearanceDelay) {
            withAnimation(.spring(response: AnimationConfig.springResponse, dampingFraction: AnimationConfig.springDamping)) {
                self.shouldShowLoadingItems = true
            }
        }
        
        scheduleAction(after: AnimationConfig.routeChangeDelay) {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                self.navigationPath.append(route)
            }
        }
        
        scheduleAction(after: AnimationConfig.itemDisappearanceDelay) {
            withAnimation(.easeInOut(duration: AnimationConfig.fadeDuration)) {
                self.shouldShowLoadingItems = false
            }
        }
        
        scheduleAction(after: AnimationConfig.backgroundDisappearanceDelay) {
            self.animateTransitionState(to: false, duration: 0.8)
        }
    }
    
    // MARK: - Private Helpers
    private func animateTransitionState(to isActive: Bool, duration: Double = 0.5) {
        withAnimation(.easeInOut(duration: duration)) {
            self.isTransitioning = isActive
        }
    }
    
    private func scheduleAction(after delay: Double, action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: action)
    }
    
    private func performBackTransition(action: @escaping () -> Void) {
        self.shouldShowLoadingItems = false
        
        withAnimation(.easeInOut(duration: 0.5)) {
            self.isTransitioning = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            action()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                self.isTransitioning = false
            }
        }
    }
}
