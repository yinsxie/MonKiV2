//
//  AppCoordinatorView.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import Combine
import SwiftUI

final class AppCoordinator: ObservableObject {
    @Published var navigationPath: [RootRoute] = []
    
    @Published var root: RootRoute = .splashScreen
    
    /// Change Root fade animation, clears navigation stack, make the push mainRoute as the new root
    /// Use this to change between major app flows
    /// e.g. from Splash to Onboarding to Garden or from Splash Directly to Garden
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
    
    func pop(times n: Int) {
        guard n > 0 else { return }
        let countToRemove = min(n, navigationPath.count)
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
}

