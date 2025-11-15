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
            RoundedRectangle(cornerRadius: 5)
                .fill(money.color)
                .frame(width: 100, height: 50)
            
            Text("\(money.price)")
                .font(.bodyRegular)
                .foregroundColor(.black)
        }
    }
}
