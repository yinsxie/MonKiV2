//
//  StartingPageView.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import SwiftUI

struct StartingPageView: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    var body: some View {
        ZStack {
            Image("landing_background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Image("placard")
                    .resizable()
                    .scaledToFit()
                
                VStack(spacing: 16) {
                    Button(action: {
                        AudioManager.shared.play(.buttonClick)
//                        appCoordinator.goTo(.play(.play))
                        appCoordinator.goTo(.helperScreen(.pickChef))
                    }, label: {
                        Image("1P_button")
                            .resizable()
                            .scaledToFit()
                    })
                    
                    Button(action: {
                        AudioManager.shared.play(.buttonClick)
                    }, label: {
                        Image("2P_button")
                            .resizable()
                            .scaledToFit()
                    })
                    .disabled(true)
                    
                    Button(action: {
                        AudioManager.shared.play(.buttonClick)
                        appCoordinator.goTo(.helperScreen(.dishBook))
                    }, label: {
                        Text("Book")
                    })
                }
            }
            .padding(115)
        }
    }
}

#Preview {
    StartingPageView()
        .environmentObject(AppCoordinator())
}
