//
//  MoneyView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 14/11/25.
//

import SwiftUI

struct MoneyView: View {
    let money: Money
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(money.color)
                .frame(width: 250, height: 64)
            
            Text("\(money.price)")
                .font(.custom("WendyOne-Regular", size: 40))
                .foregroundStyle(.white)
        }
    }
}
