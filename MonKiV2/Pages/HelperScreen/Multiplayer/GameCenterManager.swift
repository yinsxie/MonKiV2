//
//  GameCenterManager.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 25/11/25.
//
import GameKit
import SwiftUI
import Combine

@MainActor
class GameCenterManager: ObservableObject {
    static let shared = GameCenterManager()
    
    @Published var isAuthenticated = false
    @Published var currentPlayerName: String = "Player"
    @Published var currentPlayerAvatar: Image?
    
    private init() {} 
    
    func authenticateUser() {
        GKLocalPlayer.local.authenticateHandler = { vc, error in
            if let vc = vc {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = windowScene.windows.first,
                      let rootVC = window.rootViewController else { return }
                rootVC.present(vc, animated: true)
            } else if GKLocalPlayer.local.isAuthenticated {
                print("✅ User is authenticated: \(GKLocalPlayer.local.displayName)")
                self.isAuthenticated = true
                self.currentPlayerName = GKLocalPlayer.local.displayName
                self.loadAvatar()
            } else {
                print("❌ Error: \(error?.localizedDescription ?? "Unknown Authentication Error")")
                self.isAuthenticated = false
            }
        }
    }
    
    func loadAvatar() {
        GKLocalPlayer.local.loadPhoto(for: .normal) { image, error in
            if let image = image {
                DispatchQueue.main.async {
                    self.currentPlayerAvatar = Image(uiImage: image)
                }
            }
        }
    }
}
