//
//  DragModifiers.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//

import SwiftUI

/// For views that act as drag source
struct DraggableModifier: ViewModifier {
    let item: DraggedItem
    @Environment(DragManager.self) var manager
    
    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(coordinateSpace: .named("GameSpace"))
                    .onChanged { value in
                        if !manager.isDragging {
                            // Haptic feedback could go here
                            manager.isDragging = true
                            manager.currentDraggedItem = item
                        }
                        manager.currentDragLocation = value.location
                    }
                    .onEnded { _ in
                        manager.handleDrop()
                    }
            )
    }
}

/// For views that act as drag destination
struct DropZoneModifier: ViewModifier {
    let type: DropZoneType
    @Environment(DragManager.self) var manager
    @State private var zoneID = UUID() // Unique ID for this specific view instance
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            manager.updateZone(id: zoneID, frame: geo.frame(in: .named("GameSpace")), type: type)
                        }
                        .onChange(of: geo.frame(in: .named("GameSpace"))) { _, newFrame in
                            manager.updateZone(id: zoneID, frame: newFrame, type: type)
                        }
                }
            )
    }
}

extension View {
    func makeDraggable(item: DraggedItem) -> some View {
        self.modifier(DraggableModifier(item: item))
    }
    
    func makeDropZone(type: DropZoneType) -> some View {
        self.modifier(DropZoneModifier(type: type))
    }
}
