//
//  PlayBackgroundView.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 15/11/25.
//

import SwiftUI

struct PlayBackgroundView: View {
    
    @Environment(PlayViewModel.self) var playVM
    
    var body: some View {
        GeometryReader { geo in
            let backgroundSplitHeight = geo.size.height * (753 / 1024.0)
            var topColorHex: String {
                if playVM.getCurrentPage() == .createDish {
                    return "#FF7E1D"
                } else if playVM.getCurrentPage() == .shelfB {
                    return "#FFC200"
                } else {
                    return "#27A8DF"
                }
            }
            
            // MARK: Change index if turning on Debug IngredientsListView
            VStack(spacing: 0) {
                Color(hex: topColorHex).opacity(0.5)
                    .frame(height: backgroundSplitHeight)
                Color(hex: playVM.getCurrentPage() == .createDish ? "FFC200" : "#85DCFA").opacity(0.5)
            }
            .ignoresSafeArea()
        }
    }
}
