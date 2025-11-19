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
                Image(money.currency.imageAssetPath)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250)
                    .brightness(-0.3)
                    .offset(x: 6, y: 6)
            }
            
            Image(money.currency.imageAssetPath)
                .resizable()
                .scaledToFit()
                .frame(width: 250)
        }
    }
}
