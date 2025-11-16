//
//  WalletView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 14/11/25.
//

import SwiftUI

struct WalletView: View {
    @Environment(WalletViewModel.self) var viewModel
    @Environment(DragManager.self) var manager
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                ForEach(viewModel.moneys.reversed().indices, id: \.self) { index in
                    let money = viewModel.moneys.reversed()[index]
                    
                    MoneyView(money: money)
                        .opacity(manager.currentDraggedItem?.id == money.id ? 0 : 1)
                        .makeDraggable(item: DraggedItem(id: money.id, payload: .money(money.price)))
                }
            }
            Image("Wallet")
                .resizable()
                .scaledToFit()
                .frame(height: 250)
        }
    }
}
