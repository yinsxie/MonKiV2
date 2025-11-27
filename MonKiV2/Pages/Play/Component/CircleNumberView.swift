//
//  CircleNumberView.swift
//  MonKiV2
//
//  Created by William on 20/11/25.
//

import SwiftUI

struct CircleNumberView: View {
    let number: Int
    var size: CGFloat = 70
    var fontSize: CGFloat = 30
    // Inner white circle
    var body: some View {
        ZStack {
            // Outer grey ring
            Circle()
                .fill(Color(.systemGray3))
            
            Circle()
                .fill(Color.white)
                .padding(10)
            
            Text("\(number)")
                .font(.fredokaOne(size: fontSize))
                .foregroundColor(Color(.darkGray))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    CircleNumberView(number: 5)
}
