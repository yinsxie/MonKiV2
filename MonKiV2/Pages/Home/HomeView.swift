//
//  HomeView.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import SwiftUI
import GameKit

struct HomeView: View {
    
    @StateObject private var game = RealTimeGame()
    
    var body: some View {
        VStack {
            Button {
                if game.automatch {
                    // Turn automatch off.
                    GKMatchmaker.shared().cancel()
                    game.automatch = false
                }
                game.choosePlayer()
            } label: {
                Text("Test Game Center")
            }
        }
    }
}

#Preview {
    HomeView()
}
