//
//  WalletView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 14/11/25.
//

import SwiftUI

struct WalletView: View {
    var viewModel: WalletViewModel
    @Environment(DragManager.self) var manager
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .background(Color.black.opacity(0.3))
                .frame(width: 300)
                .shadow(radius: 5)
                .zIndex(0)
            
            VStack(spacing: -20) {
                ForEach(viewModel.moneys.reversed()) { moneyItem in
                    MoneyView(money: moneyItem)
                        .makeDraggable(item: DraggedItem(
                            id: moneyItem.id,
                            payload: .money(moneyItem.price)
                        ))
                        .opacity(manager.currentDraggedItem?.id == moneyItem.id ? 0 : 1)
                }
            }
            .padding(.bottom, 70)
            .zIndex(1)
            
            Text("Total: \(viewModel.totalMoney.formatted())")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 10)
                .zIndex(2)
        }
        .makeDropZone(type: .cashierPaymentCounter)
        .frame(width: 300, height: 200)
    }
}
