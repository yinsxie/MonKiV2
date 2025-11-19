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
    
    // Store views here
    private var pages: [AnyView] {
        [
            AnyView(ShelfView()),
            AnyView(CashierView()),
            AnyView(Color.clear),
            AnyView(IngredientInputView()),
            AnyView(CreateDishView())
        ]
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            PlayBackgroundView()
            
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
            
            .overlay(alignment: .topLeading) {
                Button(action: {
                    AudioManager.shared.play(.buttonClick)
                    appCoordinator.popToRoot()
                }, label: {
                    Image("home_button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 112, height: 112)
                })
                .padding(.leading, 80)
                .padding(.top, 80)
                .ignoresSafeArea(.all)

            }
            
            .overlay(alignment: .bottomTrailing) {
                let currentIndex = playVM.currentPageIndex ?? 0
                if currentIndex < 3 {
                    WalletView()
//                        .padding(.bottom, 50)
                        .padding(.trailing, 30)
                        .offset(y: 125)
                }
            }
            
            AnimationOverlayView()
            
            let currentIndex = playVM.currentPageIndex ?? 0
            let cartVisibleIndices = [0, 1]
            
            CartView()
                .offset(y: 160)
                .opacity(cartVisibleIndices.contains(currentIndex) ? 1 : 0)
            
            DragOverlayView()
        }
        .environment(playVM)
        .environment(playVM.cartVM)
        .environment(playVM.shelfVM)
        .environment(playVM.cashierVM)
        .environment(playVM.walletVM)
        .environment(playVM.dragManager)
        .environment(playVM.dishVM)
        .coordinateSpace(name: "GameSpace")
    }
}

#Preview {
    PlayViewContainer()
        .environmentObject(AppCoordinator())
}
