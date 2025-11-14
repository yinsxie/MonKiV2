//
//  MasterPlayView.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import SwiftUI

struct PlayViewContainer: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State private var playEngine = PlayEngine()
    @StateObject var session: GameSessionData = GameSessionData(forGameMode: .singlePlayer)
    @StateObject private var createDishVM = CreateDishViewModel()
    // Store views here
    private var pages: [AnyView] {
        [
            AnyView(ShelfView(viewModel: playEngine.shelfVM)),
            AnyView(Color.red.overlay(Text("Page 1"))),
            AnyView(Color.green.overlay(Text("Page 2"))),
            AnyView(CashierLoadingView()),
            AnyView(CashierPaymentView()),
            AnyView(IngredientInputView(viewModel: createDishVM)),
            AnyView(CreateDishView(viewModel: createDishVM))
        ]
    }
    
    var body: some View {
        ZStack {
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(pages.indices, id: \.self) { index in
                        pages[index]
                            .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                            .ignoresSafeArea()
                            .environmentObject(session)
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .contentMargins(0, for: .scrollContent)
            .scrollTargetBehavior(.paging)
            .scrollDisabled(playEngine.dragManager.isDragging)
            
            VStack {
                Spacer()
                CartView(viewModel: playEngine.cartVM)
                    .padding(.bottom, 50)
            }
            
            DragOverlayView()
        }
        .environment(playEngine.dragManager) // inject the dragManager into the environment so Modifiers can find it
        .coordinateSpace(name: "GameSpace")
    }
}
#Preview {
    PlayViewContainer()
        .environmentObject(AppCoordinator())
}
