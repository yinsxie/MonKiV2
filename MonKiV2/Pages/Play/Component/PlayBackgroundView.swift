//
//  PlayBackgroundView.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 15/11/25.
//

import SwiftUI

struct PlayBackgroundView: View {
    var body: some View {
        GeometryReader { geo in
            let backgroundSplitHeight = geo.size.height * (753 / 1024.0)
            
            VStack(spacing: 0) {
                Color(hex: "#27A8DF").opacity(0.5)
                    .frame(height: backgroundSplitHeight)
                Color(hex: "#85DCFA").opacity(0.5)
            }
            .ignoresSafeArea()
        }
    }
}
