//
//  ATMView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 18/11/25.
//

import SwiftUI

struct ATMView: View {
    @Environment(ATMViewModel.self) var atmVM
    @Namespace private var atmNamespace
    
    var body: some View {
        ZStack {
            if atmVM.isZoomed {
                Color.black.opacity(0.01)
                    .ignoresSafeArea()
                    .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                    .zIndex(0)
                    .onTapGesture {
                        atmVM.handleCloseATM()
                    }
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.width < -50 {
                                    atmVM.handleCloseAndScrollToShelf()
                                }
                            }
                    )
            }
            
            // MARK: - ATM KESELURUHAN (Normal atau Zoomed)
            ATMMachineView(balanceShown: true)
                .matchedGeometryEffect(id: "ATM_FULL_MACHINE", in: atmNamespace, isSource: atmVM.isZoomed == false)
            
                .scaleEffect(atmVM.isZoomed ? 2.5 : 1.0)
                .offset(y: atmVM.isZoomed ? 420 : -35)
                .zIndex(1)
                .onTapGesture {
                    if !atmVM.isZoomed {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            atmVM.handleOpenATM()
                        }
                    }
                }
            
            if !atmVM.isZoomed {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 300, height: 400)
                    .offset(y: 50)
                    .background(GeometryReader { geo in
                        Color.clear.preference(key: ViewFrameKey.self, value: ["ATM": geo.frame(in: .named("GameSpace"))])
                    })
                    .allowsHitTesting(false)
                    .zIndex(2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
