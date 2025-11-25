import GameKit
import SwiftUI
import Combine

struct GamePacket: Codable {
    enum PacketType: String, Codable {
        case itemPurchased      // When someone buys at cashier
        case itemAddedToDish    // When item moved from Bag -> Dish
        case itemRemovedFromDish // When item moved from Dish -> Bag
    }
    
    let type: PacketType
    let itemName: String
}

protocol MatchManagerDelegate: AnyObject {
    func didRemotePlayerPurchase(itemName: String)
    func didRemotePlayerAddToDish(itemName: String)
    func didRemotePlayerRemoveFromDish(itemName: String)
}

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
    weak var delegate: MatchManagerDelegate?
    
    func sendPurchase(itemName: String) {
        sendPacket(GamePacket(type: .itemPurchased, itemName: itemName))
    }
    
    func sendAddToDish(itemName: String) {
        sendPacket(GamePacket(type: .itemAddedToDish, itemName: itemName))
    }
    
    func sendRemoveFromDish(itemName: String) {
        sendPacket(GamePacket(type: .itemRemovedFromDish, itemName: itemName))
    }
    
    private func sendPacket(_ packet: GamePacket) {
        guard let match = myMatch else {
            print("⛔️ [MatchManager] Attempted to send packet, but 'myMatch' is NIL. Connection lost?")
            return
        }
        
        do {
            let data = try JSONEncoder().encode(packet)
            try match.sendData(toAllPlayers: data, with: .reliable)
            print("🚀 [MatchManager] Sent packet: \(packet.type) - \(packet.itemName)")
        } catch {
            print("❌ [MatchManager] Failed to send: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Player Info
    @Published var otherPlayerName: String = "Waiting..."
    @Published var otherPlayerAvatar: Image?
    
    // MARK: - Handshake Status
    @Published var isRemotePlayerReady = false
    @Published var isLocalPlayerReady = false
    
    
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
                self.resetMatch()
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
