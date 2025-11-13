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

    var pages: [AnyView] {
        [
            AnyView(ShelfView(viewModel: playEngine.shelfVM)),
            AnyView(Color.green.overlay(Text("Page 2"))),
            AnyView(Color.blue.overlay(Text("Page 3"))),
            AnyView(Color.yellow.overlay(Text("Page 4"))),
            AnyView(Color.orange.overlay(Text("Page 5")))
        ]
    }
    
    var body: some View {
        ZStack {
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(pages.indices, id: \.self) { index in
                        pages[index]
                            .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                            .frame(height: .infinity)
                            .ignoresSafeArea()
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
