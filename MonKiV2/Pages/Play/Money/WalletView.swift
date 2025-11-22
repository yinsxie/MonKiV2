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
    @Environment(PlayViewModel.self) var playVM
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if viewModel.isWalletOpen {
                VStack(spacing: 0) {
                    Image("wallet_overlay_header")
                        .resizable()
                        .scaledToFit()
                        .offset(y: 1)
                    
                    VStack(spacing: 15) {
                        if let budget = viewModel.parent?.currentBudget {
                            Text("\(budget.formatted())")
                                .font(.fredokaOne(size: 42))
                                .frame(maxWidth: .infinity)
                        }
                        
                        VStack(alignment: .center, spacing: 30) {
                            ForEach(viewModel.walletSorted) { moneyGroup in
                                MoneyView(money: moneyGroup.money, quantity: moneyGroup.count, width: 160)
                                    .opacity(((manager.currentDraggedItem?.id == moneyGroup.money.id) && (moneyGroup.count == 1)) ? 0 : 1)
                                    .makeDraggable(
                                        item: DraggedItem(
                                            id: moneyGroup.money.id,
                                            payload: .money(moneyGroup.money.currency)
                                        )
                                    )
                                    .offset(x: -(4 * min(CGFloat(moneyGroup.count - 1), 2)))
                                    .fixedSize()
                            }
                        }
                        .padding(.top, viewModel.walletSorted.count == 0 ? 0 : 25)
                        .padding(.bottom, viewModel.walletSorted.count == 0 ? 0 : 35)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(ColorPalette.neutral50)
                        )
                        .padding(.horizontal, 15)
                        .padding(.bottom, 35)
                    }
                    .background(ColorPalette.overlayBackground)
                    .padding(.bottom, 240)
                }
                .frame(width: 250.76)
                .transition(.move(edge: .bottom))
            }
            
            Image("Wallet")
                .resizable()
                .scaledToFit()
                .frame(height: 250)
                .onTapGesture {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                        viewModel.isWalletOpen.toggle()
                    }
                }
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .onChange(of: playVM.currentPageIndex) { _, _ in
            if playVM.cashierVM.currentPage == .payment {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    viewModel.isWalletOpen = true
                }
            } else {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    viewModel.isWalletOpen = false
                }
            }
        }
        .makeDropZone(type: .wallet)
    }
    
}

#Preview {
    PlayViewContainer()
}
