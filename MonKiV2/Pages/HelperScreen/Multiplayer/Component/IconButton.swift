//
//  IconButton.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 29/11/25.
//

import SwiftUI

struct IconButton: View {
    let iconName: String
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            AudioManager.shared.play(.buttonClick)
            action()
        }, label: {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        })
    }
}
