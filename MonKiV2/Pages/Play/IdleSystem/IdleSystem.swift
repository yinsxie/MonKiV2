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
                Color.black.opacity(0.7)
                    .mask(
                        ZStack {
                            // 1. Base Canvas (White = Opaque Overlay)
                            Color.white
                            
                            // 2. The Holes (Black = Transparent Hole)
                            ForEach(items, id: \.id) { item in
                                let rect = geo[item.anchor]
                                
                                if geo.frame(in: .local).intersects(rect) {
                                    
                                    // Check if this ID has a custom image associated with it
                                    if let imageName = getImageName(for: item.id) {
                                        // CUSTOM SHAPE LOGIC
                                        Image(imageName)
                                            .renderingMode(.template) // 1. Strip colors
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(.black)  // 2. Make pure black (Hole)
                                            .frame(width: rect.width, height: rect.height)
                                            .position(x: rect.midX, y: rect.midY)
                                    } else {
                                        // DEFAULT RECTANGLE LOGIC (Fallback)
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.black)
                                            .frame(width: rect.width + 20, height: rect.height + 20)
                                            .position(x: rect.midX, y: rect.midY)
                                    }
                                }
                            }
                        }
                        .compositingGroup()
                        .luminanceToAlpha()
                    )
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onWakeUp()
                    }
                    .transition(.opacity)
            }
            .zIndex(999)
        }
    }
    
    // MARK: - Image Lookup Helper
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
