//
//  DragOverlayView.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//

import SwiftUI

struct DragOverlayView: View {
    @Environment(DragManager.self) var manager
    @Environment(PlayViewModel.self) var playVM
    
    var body: some View {
        ZStack {
            ForEach(playVM.floatingItems) { fall in
                FloatingItemFeedbackView(
                    id: fall.id,
                    item: fall.item,
                    startPoint: fall.startPoint,
                    originPoint: fall.originPoint,
                    trackedItemID: fall.trackedItemID,
                    onAnimationComplete: { id, trackedItemID, wasFadingOut in
                        playVM.clearVisualAnimationState(id: id, trackedItemID: trackedItemID, wasFadingOut: wasFadingOut)
                    },
                    shouldFadeOut: fall.shouldFadeOut
                )
            }
            
            if let item = manager.currentDraggedItem {
                Group {
                    switch item.payload {
                    case .grocery(let groceryItem):
                        GroceryItemView(item: groceryItem)
                    case .money(let currency):
                        MoneyView(money: Money(forCurrency: currency), isBeingDragged: true)
                    }
                }
                .position(manager.currentDragLocation)
                .allowsHitTesting(false)
            }
        }
    }
}
