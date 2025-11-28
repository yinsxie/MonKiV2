//
//  BudgetSharingViewModel.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 26/11/25.
//
import SwiftUI
import GameKit

@MainActor
@Observable class BudgetSharingViewModel {
    private struct Config {
        static let animationFast = 0.1
        static let startXRange = 0.4...0.6
        static let startYRange = 0.3...0.6
        static let scatterX = -0.05...0.05
        static let scatterY = 0.0...0.1
    }
    
    var parent: PlayViewModel?
    
    var sharedMoneys: [SharedMoney] = []
    
    var amIHost: Bool = false
    var myRole: BudgetRole { amIHost ? .host : .guest }
    var isLocalReady: Bool = false
    var isRemoteReady: Bool = false
    
    var totalContainerSize: CGSize = .zero
    var hostZoneFrame: CGRect = .zero
    var guestZoneFrame: CGRect = .zero
    var breakerFrame: CGRect = .zero
    
    var hostTotal: Int { calculateTotal(for: .host) }
    var guestTotal: Int { calculateTotal(for: .guest) }
    
    var myTotal: Int { amIHost ? hostTotal : guestTotal }
    var theirTotal: Int { amIHost ? guestTotal : hostTotal }
    
    var myReadyStatusText: String {
        if (isLocalReady && isRemoteReady) {
            return "Game Starting..."
        }
        else if (isLocalReady) {
            return "UNREADY"
        }
        else {
            return "READY"
        }
    }
    
    var myReadyStatusColor: Color {
        if (isLocalReady && isRemoteReady) {
            return Color.green
        }
        
        if (isLocalReady) {
            return Color.yellow
        }
        
        if (isDistributionComplete) {
            return Color.blue
        }
        
        return Color.gray.opacity(0.5)
        
    }
    
    var isDistributionComplete: Bool {
        sharedMoneys.allSatisfy { $0.owner != nil }
    }
    
    init(parent: PlayViewModel) {
        self.parent = parent
    }
    
    func checkForHostStatus() {
        guard sharedMoneys.isEmpty else { return }
        guard let match = parent?.matchManager?.myMatch else { return }
        
        let myID = GKLocalPlayer.local.gamePlayerID
        let theirID = match.players.first?.gamePlayerID ?? ""
        
        self.amIHost = (myID < theirID)
        
        if amIHost {
            print("👑 I am Host (Left Side)")
            initializeGame(totalBudget: parent?.initialBudget ?? 50)
        } else {
            print("👤 I am Guest (Right Side)")
        }
    }
    
    func initializeGame(totalBudget: Int) {
        let breakdown = Currency.breakdown(from: totalBudget)
        
        self.sharedMoneys = breakdown.map { currency in
            SharedMoney(
                id: UUID(),
                currency: currency,
                position: CGPoint(
                    x: Double.random(in: Config.startXRange),
                    y: Double.random(in: Config.startYRange)
                ),
                owner: nil,
                lockedBy: nil
            )
        }
        
        parent?.matchManager?.sendBudgetEvent(.initialSync(self.sharedMoneys))
    }
    
    // MARK: Drag Logic
    func onDragStart(id: UUID) {
        guard let index = sharedMoneys.firstIndex(where: { $0.id == id }) else { return }
        
        sharedMoneys[index].lockedBy = myRole
        
        parent?.matchManager?.sendBudgetEvent(.dragStart(id: id, lockedBy: myRole))
    }
    
    func onDragChanged(id: UUID, location: CGPoint) {
        guard let index = sharedMoneys.firstIndex(where: { $0.id == id }) else { return }
        
        let normalizedPos = CGPoint(
            x: location.x / totalContainerSize.width,
            y: location.y / totalContainerSize.height
        )
        
        sharedMoneys[index].position = normalizedPos
        
        parent?.matchManager?.sendBudgetEvent(.move(id: id, position: normalizedPos))
    }
    
    func onDragEnded(id: UUID, location: CGPoint) {
        guard let index = sharedMoneys.firstIndex(where: { $0.id == id }) else { return }
        
        let normalizedPos = CGPoint(
            x: location.x / totalContainerSize.width,
            y: location.y / totalContainerSize.height
        )
        
        sharedMoneys[index].position = normalizedPos
        sharedMoneys[index].lockedBy = nil
        
        let newOwner = determineOwner(at: location)
        sharedMoneys[index].owner = newOwner
        
        if isInsideBreaker(location) {
            breakMoney(sharedMoneys[index])
            return
        }
        
        parent?.matchManager?.sendBudgetEvent(.dragEnd(id: id, position: normalizedPos, owner: newOwner))
    }
    
    func toggleReady() {
        isLocalReady.toggle()
        parent?.matchManager?.sendBudgetEvent(.playerReady(isReady: isLocalReady))
        checkGameStart()
    }
    
    // MARK: - Network Handling
    func handleEvent(_ event: BudgetEvent) {
        switch event {
        case .initialSync(let moneys):
            self.sharedMoneys = moneys
            
        case .dragStart(let id, let lockedBy):
            if let index = getIndex(for: id) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    sharedMoneys[index].lockedBy = lockedBy
                }
            }
            
        case .move(let id, let position):
            if let index = getIndex(for: id) {
                withAnimation(.linear(duration: Config.animationFast)) {
                    sharedMoneys[index].position = position
                }
            }
            
        case .dragEnd(let id, let position, let owner):
            if let index = getIndex(for: id) {
                withAnimation(.spring()) {
                    sharedMoneys[index].position = position
                    sharedMoneys[index].owner = owner
                    sharedMoneys[index].lockedBy = nil
                }
            }
            
        case .breakMoney(let oldID, let newMoneys):
            withAnimation {
                sharedMoneys.removeAll(where: { $0.id == oldID })
                sharedMoneys.append(contentsOf: newMoneys)
            }
            
        case .playerReady(let isReady):
            self.isRemoteReady = isReady
            checkGameStart()
        }
    }
    
    // MARK: - Helpers
    private func determineOwner(at point: CGPoint) -> BudgetRole? {
        if hostZoneFrame.contains(point) { return .host }
        if guestZoneFrame.contains(point) { return .guest }
        return nil
    }
    
    private func isInsideBreaker(_ point: CGPoint) -> Bool {
        return breakerFrame.contains(point)
    }
    
    private func breakMoney(_ money: SharedMoney) {
        let breakdown = getNextSmallestBreakdown(for: money.currency)
        guard !breakdown.isEmpty else { return }
        
        let newMoneys = breakdown.map { currency in
            SharedMoney(
                id: UUID(),
                currency: currency,
                position: CGPoint(
                    x: money.position.x + Double.random(in: Config.scatterX),
                    y: money.position.y + Double.random(in: Config.scatterY)
                ),
                owner: nil,
                lockedBy: nil
            )
        }
        
        sharedMoneys.removeAll(where: { $0.id == money.id })
        sharedMoneys.append(contentsOf: newMoneys)
        
        parent?.matchManager?.sendBudgetEvent(.breakMoney(oldID: money.id, newMoneys: newMoneys))
    }
    
    private func checkGameStart() {
        if isLocalReady && isRemoteReady {
            print("✅ Budget Split Done! Distributing Money...")
            
            let myShare = sharedMoneys
                .filter { $0.owner == myRole }
                .map { $0.currency }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.parent?.walletVM.addMoney(myShare)
                withAnimation {
                    self.parent?.isBudgetSharingActive = false
                }
            }
        }
    }
    
    private func getIndex(for id: UUID) -> Int? {
        sharedMoneys.firstIndex(where: { $0.id == id })
    }
    
    private func calculateTotal(for role: BudgetRole) -> Int {
        sharedMoneys.filter { $0.owner == role }.reduce(0) { $0 + $1.currency.value }
    }
    
    private func getNextSmallestBreakdown(for currency: Currency) -> [Currency] {
        switch currency {
        case .idr100: return [.idr50, .idr50]
        case .idr50: return [.idr20, .idr20, .idr10]
        case .idr20: return [.idr10, .idr10]
        case .idr10: return [.idr5, .idr5]
        case .idr5: return [.idr2, .idr2, .idr1]
        case .idr2: return [.idr1, .idr1]
        case .idr1: return []
        }
    }
}
