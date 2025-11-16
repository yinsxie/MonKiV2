//
//  MonKiV2App.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import SwiftUI

@main
struct MonKiV2App: App {
    
    // MARK: Project Init
    @StateObject var appCoordinator: AppCoordinator = AppCoordinator()
    
    init() {
        _ = AudioManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
                .environmentObject(appCoordinator)
        }
    }
}
