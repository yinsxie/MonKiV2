//
//  DragManager.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//

import SwiftUI

enum DropZoneType: String {
    case cart
    case shelfReturnItem // return item to shelf
    case cashierLoadingCounter // for handing over items to be bought
    case cashierPaymentCounter // for handing over money
    case wallet // for handling kembalian
    case cashierRemoveItem // for removing cart item
}

enum PayloadSourceType {
    case cart
    case cashierCounter
}

struct DraggedItem: Equatable {
    var id: UUID = UUID()
    var payload: DragPayload
    var source: PayloadSourceType?
        
    static func == (lhs: DraggedItem, rhs: DraggedItem) -> Bool {
        lhs.id == rhs.id
    }
}

enum DragPayload: Equatable {
    case grocery(Item)
     case money(Int)
}

@Observable class DragManager {
    var currentDraggedItem: DraggedItem?
    var currentDragLocation: CGPoint = .zero
    var isDragging: Bool = false
    var dragStartLocation: CGPoint = .zero
    
    var dropZones: [UUID: (frame: CGRect, type: DropZoneType)] = [:]
    
    var onDropSuccess: ((DropZoneType, DraggedItem) -> Void)?
    var onDropFailed: ((DraggedItem) -> Void)?
    
    func updateZone(id: UUID, frame: CGRect, type: DropZoneType) {
        dropZones[id] = (frame, type)
    }
    
    func handleDrop() {
        isDragging = false
        
        guard let item = currentDraggedItem else { return }
        
        for (_, zone) in dropZones where zone.frame.contains(currentDragLocation) {
            print("Hit zone: \(zone.type)")
                        
            onDropSuccess?(zone.type, item)
            break
        }
        
        print("Hit no valid zone. Failing drop.")
        onDropFailed?(item)
    }
    
    func startDrag(_ item: DraggedItem, at startLocation: CGPoint) {
        if isDragging { return }
        
        self.dragStartLocation = startLocation
        self.isDragging = true
        self.currentDraggedItem = item
        AudioManager.shared.play(.pickShelf, pitchVariation: 0.04)
    }
}
