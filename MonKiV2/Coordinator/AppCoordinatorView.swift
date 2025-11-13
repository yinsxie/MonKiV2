//
//  AppCoordinatorView.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import SwiftUI

struct AppCoordinatorView: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    var body: some View {
        
        /// The main navigation stack that handles the app's navigation flow.
        NavigationStack(path: $appCoordinator.navigationPath) {
            appCoordinator.buildRoot(appCoordinator.root)
                .navigationDestination(for: RootRoute.self, destination: { route in
                    switch route {
                    case .play(let playRoute):
                        playRoute.delegateView()
                            .navigationBarBackButtonHidden(true)
                    default:
                        Text("Unhandled Route")
                            .navigationBarBackButtonHidden(true)
                    }
                })
        }
        .onAppear {
            setupAppFlow()
            endSplashView()
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
}
