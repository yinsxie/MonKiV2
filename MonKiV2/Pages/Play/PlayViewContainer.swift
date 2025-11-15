//
//  MasterPlayView.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import SwiftUI

struct PlayViewContainer: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State private var playVM = PlayViewModel()
    @StateObject private var createDishVM = CreateDishViewModel()

    // Store views here
    private var pages: [AnyView] {
        [
            AnyView(ShelfView()),
            AnyView(CashierLoadingView()),
            AnyView(CashierPaymentView()),
            AnyView(IngredientInputView(viewModel: createDishVM)),  // can be delete after cashier payment implemented
            AnyView(CreateDishView(viewModel: createDishVM))
        ]
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(pages.indices, id: \.self) { index in
                        pages[index]
                            .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                            .ignoresSafeArea()
                            .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollPosition(id: $playVM.currentPageIndex)
            .scrollBounceBehavior(.basedOnSize)
            .contentMargins(0, for: .scrollContent)
            .scrollTargetBehavior(.paging)
            .scrollDisabled(playVM.dragManager.isDragging)
            .scrollIndicators(.hidden)
            
            .overlay(alignment: .bottomTrailing) {
                let currentIndex = playVM.currentPageIndex ?? 0
                if currentIndex < 3 {
                    WalletView()
                        .padding(.bottom, 50)
                        .padding(.trailing, 20)
                }
            }
            
            .overlay(alignment: .bottom) {
                let currentIndex = playVM.currentPageIndex ?? 0
                let cartVisibleIndices = [0, 1]
                
                if cartVisibleIndices.contains(currentIndex) {
                    CartView()
                        .offset(y: 160)
                }
            }
            
            DragOverlayView()
        }
        .environment(playVM)
        .environment(playVM.cartVM)
        .environment(playVM.shelfVM)
        .environment(playVM.cashierVM)
        .environment(playVM.walletVM)
        .environment(playVM.dragManager)
        .coordinateSpace(name: "GameSpace")
    }
}

#Preview {
    PlayViewContainer()
        .environmentObject(AppCoordinator())
}
