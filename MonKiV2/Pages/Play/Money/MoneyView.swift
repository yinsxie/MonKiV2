//
//  MoneyView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 14/11/25.
//

import SwiftUI

struct MoneyView: View {
    let money: Money
    var isMoreThanOne: Bool = false
    var isBeingDragged: Bool = false
    
    var body: some View {
        ZStack {
            if isMoreThanOne {
                Rectangle()
                    .fill(money.currency.backgroundColor).brightness(-0.25)
                    .frame(width: 250, height: isBeingDragged ? 128 : 64)
                    .offset(x: 8, y: 8)
            }
            
            Rectangle()
                .fill(money.currency.backgroundColor)
                .frame(width: 250, height: isBeingDragged ? 128 : 64)
            
            Text("\(money.currency.value)")
                .font(.custom("WendyOne-Regular", size: 40))
                .foregroundStyle(.white)
        }
    }
}
