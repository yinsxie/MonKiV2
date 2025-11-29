//
//  ScaleWrapper.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 29/11/25.
//

import SwiftUI

struct GameRootScaler<Content: View>: View {
    let content: Content
    
    let designWidth: CGFloat = 1366
    let designHeight: CGFloat = 1024
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geo in
            // Calculate scale to fit (keeps aspect ratio)
            let scale = min(geo.size.width / designWidth, geo.size.height / designHeight)
            
            ZStack {
                // "Letterbox" Background
                // (Visible on iPad Mini, iPad Air, or iPhones)
                Color.black
                    .ignoresSafeArea()
                
                content
                    .frame(width: designWidth, height: designHeight)
                    .scaleEffect(scale) // Shrink to fit actual screen
                    .position(x: geo.size.width / 2, y: geo.size.height / 2) // Center it
            }
        }
        .ignoresSafeArea()
        .defersSystemGestures(on: .all)
    }
}
