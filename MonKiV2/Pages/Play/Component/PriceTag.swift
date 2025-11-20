//
//  PriceTag.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 20/11/25.
//
import SwiftUI

struct PriceTag: View {
    let price: Int32
    
    var body: some View {
        ZStack(alignment: .leading) {
            Image("pricetag")
                .resizable()
                .scaledToFit()
                .frame(height: 51)
            HStack {
                Image("coin")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 32)
                Text("\(price)")
                    .font(.fredokaOne(size: 28))
                    .foregroundColor(.white)
            }
            .padding(.leading, 50)
        }
    }
}
