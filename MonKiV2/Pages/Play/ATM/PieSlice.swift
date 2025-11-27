//
//  PieSlice.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 18/11/25.
//

import SwiftUI

struct PieSlice: Shape {
    var progress: Double
    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: .degrees(0), endAngle: .degrees(360 * progress), clockwise: false)
        path.closeSubpath()
        return path
    }
}
