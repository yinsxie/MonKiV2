import GameKit
import SwiftUI
import Combine

@MainActor
class MatchManager: NSObject, ObservableObject {
    // MARK: - Game State
    enum MatchState {
        case idle
        case searching
        case connected
        case playing
    }
    
    @Published var matchState: MatchState = .idle
    @Published var myMatch: GKMatch?
    
    // MARK: - Player Info
    @Published var otherPlayerName: String = "Waiting..."
    @Published var otherPlayerAvatar: Image?
    
    // MARK: - Handshake Status
    @Published var isRemotePlayerReady = false
    @Published var isLocalPlayerReady = false
    
    // MARK: - Authentication
    func authenticateUser() {
        GKLocalPlayer.local.authenticateHandler = { vc, error in
            if let vc = vc {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = windowScene.windows.first,
                      let rootVC = window.rootViewController else { return }
                rootVC.present(vc, animated: true)
            } else if GKLocalPlayer.local.isAuthenticated {
                print("User is authenticated")
            } else {
                print("Error: \(error?.localizedDescription ?? "Unknown Authentication Error")")
            }
        }
    }
    
    // MARK: - Matchmaking Logic
    func startMatchmaking(withCode code: Int = 0) {
        self.matchState = .searching
        
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        request.playerGroup = code
        
        GKMatchmaker.shared().findMatch(for: request) { match, error in
            if let match = match {
                self.myMatch = match
                self.myMatch?.delegate = self
                
                if !match.players.isEmpty {
                    self.loadOpponentDetails(player: match.players[0])
                }
                
                self.matchState = .connected
                
            } else if let error = error {
                print("Matchmaking failed: \(error.localizedDescription)")
                self.matchState = .idle
            }
        }
    }
    
    func cancelMatchmaking() {
        GKMatchmaker.shared().cancel()
        self.matchState = .idle
        self.otherPlayerName = "Waiting..."
        self.otherPlayerAvatar = nil
        self.isLocalPlayerReady = false
        self.isRemotePlayerReady = false
    }
    
    // MARK: - Load Details (FIXED)
    func loadOpponentDetails(player: GKPlayer) {
        print("Loading details for: \(player.displayName)")
        
        // 1. Update Name
        DispatchQueue.main.async {
            self.otherPlayerName = player.displayName
        }
        
        // 2. Load Photo
        player.loadPhoto(for: .normal) { image, error in
            if let image = image {
                DispatchQueue.main.async {
                    self.otherPlayerAvatar = Image(uiImage: image)
                }
            } else {
                print("Could not load avatar: \(error?.localizedDescription ?? "Unknown")")
            }
        }
    }
    
    // MARK: - Handshake Logic
    func sendReadySignal() {
        guard let match = myMatch else { return }
        self.isLocalPlayerReady = true
        
        if let data = "READY".data(using: .utf8) {
            do {
                try match.sendData(toAllPlayers: data, with: .reliable)
            } catch {
                print("Failed to send ready signal")
            }
        }
        checkIfGameCanStart()
    }
    
    func checkIfGameCanStart() {
        if isLocalPlayerReady && isRemotePlayerReady {
            DispatchQueue.main.async {
                self.matchState = .playing
            }
        }
    }
    
    func resetMatch() {
        // Reset the game data.
        myMatch?.disconnect()
        myMatch?.delegate = nil
        myMatch = nil
        self.matchState = .idle
        self.otherPlayerName = "Waiting..."
        self.otherPlayerAvatar = nil
        self.isLocalPlayerReady = false
        self.isRemotePlayerReady = false
    }
}

// MARK: - GKMatchDelegate
extension MatchManager: GKMatchDelegate {
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        switch state {
        case .connected:
            print("\(player.displayName) has connected!")
            loadOpponentDetails(player: player)
        case .disconnected:
            print("\(player.displayName) disconnected")
            DispatchQueue.main.async {
                self.matchState = .idle
            }
        default:
            break
        }
    }
    
    func match(_ match: GKMatch, didFailWithError error: Error?) {
        print("Match failed: \(error?.localizedDescription ?? "Unknown")")
    }
    
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        if let message = String(data: data, encoding: .utf8) {
            if message == "READY" {
                print("Opponent is ready!")
                DispatchQueue.main.async {
                    self.isRemotePlayerReady = true
                    self.checkIfGameCanStart()
                }
            }
        }
    }
}
