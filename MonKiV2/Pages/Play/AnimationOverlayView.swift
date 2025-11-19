//
//  AnimationOverlayView.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 19/11/25.
//

import SwiftUI

struct AnimationOverlayView: View {
    @Environment(DragManager.self) var manager
    @Environment(PlayViewModel.self) var playVM
    
    var body: some View {
            
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

    }
}
