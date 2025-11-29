//
//  TotalPiceView.swift
//  MonKiV2
//
//  Created by William on 27/11/25.
//

import SwiftUI

struct TotalPiceView: View {
    @Environment(PlayViewModel.self) private var playVM
    
    let size: CGFloat = 40.0
    let cornerRadius: CGFloat = 60
    
    var body: some View {
        HStack(spacing: 11) {
            
            Image("coin")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: size)
            
            Text(playVM.currentBudget.formatted())
//            Text("\(angka.formatted())")
                .font(.fredokaMedium(size: 36, relativeTo: .title))
        }
        .padding(.vertical)
        .padding(.horizontal, 25)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(ColorPalette.neutral300, lineWidth: 6.22)
        )
    }
    
}

//#Preview {
//    TotalPiceView()
//        .environment(PlayViewModel(gameMode: .multiplayer))
//}
