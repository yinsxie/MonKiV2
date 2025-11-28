//
//  BubbleThoughtView.swift
//  MonKiV2
//
//  Created by William on 22/11/25.
//

import SwiftUI

enum ThoughtBubbleType {
    case initialPrice
    case givenMoney
}

struct BubbleThoughtView: View {
    
    @Environment(CashierViewModel.self) var cashierVM
    
    var type: ThoughtBubbleType = .initialPrice
    
    var body: some View {
        HStack(alignment: .bottom) {
            
            Image("bubble_thought_corner")
                .resizable()
                .scaledToFit()
                .frame(height: 45)
                .offset(x: 25, y: 20)
                .zIndex(-1)
            
            HStack {
                switch type {
                case .initialPrice:
                    initialPriceView()
                case .givenMoney:
                    givenMoneyView()
                }
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 20)
            .background(
                // The main bubble shape
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white)
                    .overlay(
                        // The border around the main bubble
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color(hex: "#CFD1D2"), lineWidth: 6)
                    )
            )
        }
    }
    
    @ViewBuilder
    func initialPriceView() -> some View {
        HStack(spacing: 10) {
            Image("coin")
                .resizable()
                .scaledToFit()
                .frame(width: 30)
            
            Text("\(cashierVM.totalPrice.formatted())")
                .font(.fredokaSemiBold(size: 28))
        }
    }
        
    @ViewBuilder
    func givenMoneyView() -> some View {
        // Determine number of columns dynamically
        let columnCount = min(cashierVM.receivedMoneyGrouped.count, 3)
        let perColumnSize: CGFloat = 120
        let columns: [GridItem] = Array(repeating: GridItem(.flexible(minimum: 0, maximum: perColumnSize)), count: columnCount)
        
        HStack(alignment: .center, spacing: 10) {
            VStack {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(cashierVM.receivedMoneyGrouped) { moneyGroup in
                        HStack(spacing: 10) {
                            Text("\(moneyGroup.count)")
                                .font(.fredokaMedium(size: 24))
                                .foregroundStyle(moneyGroup.money.currency.foregroundColor)
                            
                            Image(moneyGroup.money.currency.imageAssetPath)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 65)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(maxWidth: CGFloat(columnCount) * perColumnSize, alignment: .leading)
            
            Text("=")
                .font(.fredokaSemiBold(size: 28))
            
            Text("\(cashierVM.totalReceivedMoney.formatted())")
                .font(.fredokaSemiBold(size: 28))
        }
    }
    
    @ViewBuilder
    func createDish() -> some View {
        
    }

}

#Preview {
//    BubbleThoughtView(type: .givenMoney)
//        .environment(CashierViewModel(parent: PlayViewModel()))
    PlayViewContainer(forGameMode: .singleplayer)
}
