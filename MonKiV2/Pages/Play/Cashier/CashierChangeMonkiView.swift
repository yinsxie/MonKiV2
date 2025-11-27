//
//  CashierChangeMonkiView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 27/11/25.
//

import SwiftUI

struct CashierChangeMonkiView: View {
    @Environment(CashierViewModel.self) var viewModel
    
    var body: some View {
            ZStack {
                Image("monki_half body_cashier")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 403, height: 576)
                
                MonkiHandView()
                    .animation(.easeInOut(duration: 0.5), value: viewModel.isAnimatingReturnMoney)
                    .offset(y: 0)
            }
            .offset(x: -350, y: -62)
    }
}

#Preview {
    PlayViewContainer(forGameMode: .singleplayer)
}
