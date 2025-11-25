//
//  CashierMonkiView.swift
//  MonKiV2
//
//  Created by William on 22/11/25.
//

import SwiftUI

struct CashierMonkiView: View {
    @Environment(DragManager.self) var dragManager
    @Environment(CashierViewModel.self) var viewModel
    @Environment(PlayViewModel.self) var playVM
    
    @State private var bubbleOpacity: Double = 0
    
    var body: some View {
        ZStack {
            ZStack {
                Image("cashier_monki")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 402)
                
                let isFirstTimePayment = viewModel.totalPrice > 0 && dragManager.currentDraggedItem != nil
                let moneyExist = viewModel.totalReceivedMoney > 0 || viewModel.returnedMoney.count > 0
                let condition = playVM.getCurrentPage() == .cashierPayment && (isFirstTimePayment || moneyExist)
                
                MonkiHandView()
                    .opacity(condition && !viewModel.isAnimatingReturnMoney ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5), value: viewModel.isAnimatingReturnMoney)
                    .offset(y: 100)
            }
            .offset(x: -350, y: -150)

            BubbleThoughtView(type: viewModel.totalReceivedMoney > 0 ? .givenMoney : .initialPrice)
                .offset(x: -180 + (50 * CGFloat(min(viewModel.receivedMoneyGrouped.count, 3))), y: -280)
                .opacity(bubbleOpacity)
        }
        .onChange(of: playVM.currentPageIndex) {
            if viewModel.totalPrice > 0 && playVM.getCurrentPage() == .cashierPayment {
                // Fade IN — 1.5 seconds
                withAnimation(.easeInOut(duration: 1.2)) {
                    bubbleOpacity = 1
                }
            } else {
                // Fade OUT — default (fast)
                withAnimation(.easeOut(duration: 0.1)) {
                    bubbleOpacity = 0
                }
            }
        }
        .onChange(of: viewModel.totalPrice) { _, newTotalPrice in
            if newTotalPrice == 0 {
                withAnimation(.easeOut(duration: 0.1)) {
                    bubbleOpacity = 0
                }
            }
        }
    }
}

#Preview {
    PlayViewContainer(forGameMode: .singleplayer)
}
