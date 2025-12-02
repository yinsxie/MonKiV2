//
//  SharedMoney.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 26/11/25.
//
import SwiftUI

enum BudgetRole: String, Codable {
    case host
    case guest
}

struct SharedMoney: Identifiable, Codable, Equatable {
    let id: UUID
    let currency: Currency
    var position: CGPoint // Normalized (0.0 to 1.0)
    var owner: BudgetRole?

    // Drag
    var lockedBy: BudgetRole?
    var isBeingDragged: Bool = false
    
    // Helper for UI
    var rotation: Double = Double.random(in: -15...15)
}

enum BudgetEvent: Codable {
    case initialSync([SharedMoney])
    
    // Drag
    case dragStart(id: UUID, lockedBy: BudgetRole)
    case move(id: UUID, position: CGPoint)
    case dragEnd(id: UUID, position: CGPoint, owner: BudgetRole?)
    
    case breakMoney(oldID: UUID, newMoneys: [SharedMoney])
    case playerReady(isReady: Bool)
}
