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
            let isFirstTimePayment = viewModel.totalPrice > 0 && dragManager.currentDraggedItem != nil
            let moneyExist = viewModel.totalReceivedMoney > 0 || viewModel.returnedMoney.count > 0
            let condition = playVM.getCurrentPage() == .cashierPayment && (isFirstTimePayment || moneyExist)
            
            let showHands = condition && !viewModel.isAnimatingReturnMoney
            let isClipped = !viewModel.returnedMoney.isEmpty
            
            ZStack {
                Image(isClipped ? "monki_half body_cashier" : showHands ? "monki_body_cashier_2" : "monki_body_cashier_1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 403, height: 576)
                
                MonkiHandView()
                    .opacity(showHands ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5), value: viewModel.isAnimatingReturnMoney)
                    .offset(y: isClipped ? 0 : -100)
            }
            .offset(x: -350, y: isClipped ? -60 : -150)
            
            BubbleThoughtView(type: viewModel.totalReceivedMoney > 0 ? .givenMoney : .initialPrice)
                .offset(x: -200 + (50 * CGFloat(min(viewModel.receivedMoneyGrouped.count, 3))), y: -450)
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
