//
//  MonkiHandView.swift
//  MonKiV2
//
//  Created by William on 22/11/25.
//

import SwiftUI

struct MonkiHandView: View {
    
    @Environment(CashierViewModel.self) var cashierVM
    
    let columns = [
        GridItem(.fixed(120)),
        GridItem(.fixed(120))
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Spacer() // pushes the grid to the bottom

                LazyVGrid(columns: columns, spacing: 15) {
                    if cashierVM.receivedMoneyGrouped.count % 2 == 1 {
                        Spacer()
                    }
                    ForEach(cashierVM.receivedMoneyGrouped) { moneyGroup in
                        imageViewForMoney(moneyGroup.money)
                            .makeDraggable(item: DraggedItem(id: moneyGroup.money.id, payload: .money(moneyGroup.money.currency), source: .monkiHand))
                    }
                    if cashierVM.returnedMoney.count > 0 {
                        ForEach(cashierVM.returnedMoney) { money in
                            imageViewForMoney(money)
                        }
                    }
                }
            }
            .offset(y: -50)
            .frame(maxHeight: .infinity) // allows VStack to expand vertically

            Image("monki_hand")
                .resizable()
                .scaledToFit()
                .frame(width: 250)
        }

        .frame(maxWidth: 200, maxHeight: 250)
    }
    
    func imageViewForMoney(_ money: Money) -> some View {
        Image(money.currency.imageAssetPath)
            .resizable()
            .scaledToFit()
            .frame(width: 120)
    }
}

#Preview {
    PlayViewContainer()
}
