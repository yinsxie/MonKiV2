//
//  DragManager.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//

import SwiftUI

enum DropZoneType: String {
    case cart
    case cashierLoadingCounter // for handing over items to be bought
    case cashierPaymentCounter // for handing over money
}

// A wrapper for the data being dragged
struct DraggedItem: Equatable {
    var id: UUID = UUID()
    var payload: DragPayload
        
    static func == (lhs: DraggedItem, rhs: DraggedItem) -> Bool {
        lhs.id == rhs.id
    }
}

enum DragPayload: Equatable {
    case grocery(Item)
    // Future proofing:
    // case money(Double)
}

@Observable class DragManager {
    // STATE
    var currentDraggedItem: DraggedItem?
    var currentDragLocation: CGPoint = .zero
    var isDragging: Bool = false
    
    // REGISTERED ZONES (The map of the screen)
    // We store the Frame (CGRect) and the Type of zone
    var dropZones: [UUID: (frame: CGRect, type: DropZoneType)] = [:]
    
    // EVENTS
    // Your ViewModels will listen to this to know if they received an item
    var onDropSuccess: ((DropZoneType, DraggedItem) -> Void)?
    
    // LOGIC
    func updateZone(id: UUID, frame: CGRect, type: DropZoneType) {
        dropZones[id] = (frame, type)
    }
    
    func handleDrop() {
        isDragging = false
        
        for (_, zone) in dropZones {
            if zone.frame.contains(currentDragLocation) {
                if let item = currentDraggedItem {
                    print("Hit zone: \(zone.type)")
                    onDropSuccess?(zone.type, item)
                }
            }
        }
        currentDraggedItem = nil

    }
}
