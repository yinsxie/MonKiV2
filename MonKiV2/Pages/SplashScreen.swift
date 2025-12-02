//
//  SplashScreen.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 16/11/25.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            ColorPalette.orange500.ignoresSafeArea()
            
            Image("MonkiSplashLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 144)
        }
        .onAppear {
            GameCenterManager.shared.authenticateUser()
        }
    }
}

#Preview {
    SplashScreenView()
}
