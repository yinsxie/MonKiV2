//
//  IdleSystem.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 20/11/25.
//
import SwiftUI

// MARK: - 1. Logic Manager
@Observable
class InactivityManager {
    var isIdle: Bool = false
    private var timer: Timer?
    private let timeout: TimeInterval = 8.0
    
    func startMonitoring() {
        if timer == nil {
            resetTimer()
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        withAnimation { isIdle = false }
    }
    
    func userDidInteract() {
        if timer != nil {
            if isIdle {
                withAnimation(.easeOut(duration: 0.3)) { isIdle = false }
            }
            resetTimer()
        }
    }
    
    private func resetTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                withAnimation(.easeIn(duration: 0.5)) {
                    self?.isIdle = true
                }
            }
        }
    }
}

// MARK: - 2. Spotlight Preferences
struct SpotlightItem: Equatable {
    var id: String
    var anchor: Anchor<CGRect>
}

struct SpotlightKey: PreferenceKey {
    static var defaultValue: [SpotlightItem] = []
    static func reduce(value: inout [SpotlightItem], nextValue: () -> [SpotlightItem]) {
        value.append(contentsOf: nextValue())
    }
}

// MARK: - 3. The Overlay View
struct IdleSpotlightOverlay: View {
    @Binding var isIdle: Bool
    var items: [SpotlightItem]
    var onWakeUp: () -> Void
    
    var body: some View {
        if isIdle {
            GeometryReader { geo in
                let holeRects: [CGRect] = items.compactMap { item in
                    let rect = geo[item.anchor]
                    return geo.frame(in: .local).intersects(rect) ? rect : nil
                }

                ZStack {
                    // LAYER A: VISUALS (Touch Disabled)
                    VisualLayer(geo: geo, items: items)
                        .allowsHitTesting(false)
                    
                    // LAYER B: HITBOX (Touch Enabled)
                    DonutHitBox(holes: holeRects)
                        .fill(Color.white.opacity(0.01))
                        .contentShape(DonutHitBox(holes: holeRects), eoFill: true)
                        .onTapGesture {
                            onWakeUp()
                        }
                }
            }
            .zIndex(999)
        }
    }
    
    // MARK: - Component A: Visuals
    struct VisualLayer: View {
        let geo: GeometryProxy
        let items: [SpotlightItem]
        
        var body: some View {
            Color.black.opacity(0.7)
                .mask(
                    ZStack {
                        Color.white
                        ForEach(items, id: \.id) { item in
                            let rect = geo[item.anchor]
                            if geo.frame(in: .local).intersects(rect) {
                                if let imageName = getImageName(for: item.id) {
                                    Image(imageName)
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.black)
                                        .frame(width: rect.width, height: rect.height)
                                        .position(x: rect.midX, y: rect.midY)
                                } else {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.black)
                                        .frame(width: rect.width, height: rect.height)
                                        .position(x: rect.midX, y: rect.midY)
                                }
                            }
                        }
                    }
                    .compositingGroup()
                    .luminanceToAlpha()
                )
                .ignoresSafeArea()
                .transition(.opacity)
        }
        
        private func getImageName(for id: String) -> String? {
            switch id {
            case "Cart": return "cart"
            case "CornItem": return "shelf_jagung"
            case "CarrotItem": return "shelf_wortel"
            case "TomatoItem": return "shelf_tomat"
            case "BroccoliItem": return "shelf_brokoli"
            case "EggItem": return "shelf_telur"
            default: return nil
            }
        }
    }
    
    // MARK: - Component B: The Shape Logic
    struct DonutHitBox: Shape {
        var holes: [CGRect]
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            // 1. Add Full Screen Rect
            path.addRect(rect)
            
            // 2. Add Hole Rects
            for hole in holes {
                // We cut a hole slightly larger than the item
                path.addRoundedRect(
                    in: hole.insetBy(dx: -10, dy: -10),
                    cornerSize: CGSize(width: 15, height: 15)
                )
            }
            return path
        }
    }
}

// MARK: - Extensions
extension View {
    func spotlight(id: String) -> some View {
        self.anchorPreference(key: SpotlightKey.self, value: .bounds) { anchor in
            [SpotlightItem(id: id, anchor: anchor)]
        }
    }
    
    func reverseMask<Mask: View>(@ViewBuilder _ mask: () -> Mask) -> some View {
        self.mask(
            mask()
                .compositingGroup()
                .luminanceToAlpha()
        )
    }
}
