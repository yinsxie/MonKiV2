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
                ForEach(viewModel.walletSorted) { moneyGroup in
                    MoneyView(money: moneyGroup.money, isMoreThanOne: moneyGroup.count > 1)
                        .opacity(((manager.currentDraggedItem?.id == moneyGroup.money.id) && (moneyGroup.count == 1)) ? 0 : 1)
                        .makeDraggable(
                            item: DraggedItem(
                                id: moneyGroup.money.id,
                                payload: .money(moneyGroup.money.currency)
                            )
                        )
                }
            }
            Image("Wallet")
                .resizable()
                .scaledToFit()
                .frame(height: 250)
        }
    }
}
