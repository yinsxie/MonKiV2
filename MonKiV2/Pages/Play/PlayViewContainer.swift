//
//  MasterPlayView.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import SwiftUI

struct PlayViewContainer: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @StateObject var session: GameSessionData = GameSessionData(forGameMode: .singlePlayer)
    // Store views here
    let pages: [AnyView] = [
        AnyView(StartingPageView()),
        AnyView(Color.red.overlay(Text("Page 1"))),
        AnyView(Color.green.overlay(Text("Page 2"))),
        AnyView(CashierLoadingView()),
        AnyView(CashierPaymentView()),
        AnyView(Color.orange.overlay(Text("Page 5")))
    ]
    
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
        }
    }
}

#Preview {
    PlayViewContainer()
        .environmentObject(AppCoordinator())
}
