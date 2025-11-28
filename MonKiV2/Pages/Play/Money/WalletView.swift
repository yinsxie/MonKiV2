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
                openWalletContent
            } else {
                let currentBudget = playVM.currentBudget
                let breakdown = Currency.breakdown(from: currentBudget)
                
                if let largestCurrency = breakdown.max(by: { $0.value < $1.value }) {
                    Image(largestCurrency.imageAssetPath)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 270)
                        .rotationEffect(.degrees(55))
                        .offset(x: 15, y: -125)
                        .zIndex(0)
                        .transition(.opacity)
                }
                
            }
            
            walletImageButton
            
            Text("test")
            if !viewModel.isWalletOpen {
                TotalPiceView()
                    .offset(y: -200)
            }
            
            if playVM.getCurrentPage() == .ATM {
                Rectangle()
                    .foregroundColor(Color.clear)
                    .floatingPriceFeedback(value: viewModel.parent?.currentBudget ?? 0)
                    .frame(width: 100, height: 100)
                    .offset(x: -200, y: -200)
            }
            if playVM.getCurrentPage() == .cashierPayment {
                Rectangle()
                    .foregroundColor(Color.clear)
                    .floatingPriceFeedback(value: playVM.cashierVM.cumulativeReturnTotal)
                    .frame(width: 100, height: 100)
                    .offset(x: -200, y: -200)
            }
        }
        //        .frame(maxHeight: playVM.currentPageIndex == 5 ? 0 : .infinity, alignment: .bottom)
        .onChange(of: playVM.currentPageIndex) {
            handlePageChange()
        }
        .makeDropZone(type: .wallet)
    }
    
    func toggleWallet(open: Bool) {
        guard viewModel.isWalletOpen != open else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            viewModel.isWalletOpen = open
        }
    }
    
}

extension WalletView {
    
    private var openWalletContent: some View {
        VStack(spacing: 0) {
            Image("wallet_overlay_header")
                .resizable()
                .scaledToFit()
                .offset(y: 1)
                .onHeaderCloseSwipe {
                    toggleWallet(open: false)
                }
            
            VStack(spacing: 15) {
                TotalPiceView()
                    .frame(maxWidth: .infinity)
                    .onHeaderCloseSwipe {
                        toggleWallet(open: false)
                    }
                
                VStack(alignment: .center, spacing: 30) {
                    ForEach(viewModel.walletSorted) { moneyGroup in
                        let isBeingDragged = manager.currentDraggedItem?.id == moneyGroup.money.id
                        let displayCount = isBeingDragged ? (moneyGroup.count - 1) : moneyGroup.count
                        let shouldHide = displayCount <= 0
                        
                        MoneyView(
                            money: moneyGroup.money,
                            quantity: displayCount,
                            width: 160
                        )
                        .opacity(shouldHide ? 0 : 1)
                        .makeDraggable(
                            item: DraggedItem(
                                id: moneyGroup.money.id,
                                payload: .money(moneyGroup.money.currency),
                                source: .wallet
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
            .padding(.bottom, 210)
        }
        .frame(width: 250.76)
        .transition(.move(edge: .bottom))
    }
    
    private var walletImageButton: some View {
        Image("Wallet")
            .resizable()
            .scaledToFit()
            .frame(height: 228)
            .onComponentSwipe(
                open: { toggleWallet(open: true) },
                close: { toggleWallet(open: false) }
            )
            .onTapGesture {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    viewModel.isWalletOpen.toggle()
                }
            }
    }
    
    private func handlePageChange() {
        if playVM.getCurrentPage() == .cashierPayment {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                viewModel.isWalletOpen = true
            }
        } else {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                viewModel.isWalletOpen = false
            }
        }
    }
}

#Preview {
    PlayViewContainer(forGameMode: .singleplayer)
}
