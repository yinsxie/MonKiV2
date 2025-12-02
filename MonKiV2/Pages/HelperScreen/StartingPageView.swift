//
//  StartingPageView.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import SwiftUI
import ImagePlayground

struct StartingPageView: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @Environment(\.supportsImagePlayground) var supportsImagePlayground
    
    @State var isShowingMultiplayerAlert: Bool = false
    
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
                    .accessibilityLabel("Single Player")
                    
                    Button(action: {
                        AudioManager.shared.play(.buttonClick)
                        if supportsImagePlayground {
                            appCoordinator.goTo(.helperScreen(.multiplayerLobby))
                        } else {
                            withAnimation {
                                isShowingMultiplayerAlert = true
                            }
                        }
                    }, label: {
                        Image("2P_button_active")
                            .resizable()
                            .scaledToFit()
                    })
                    .accessibilityLabel("Multiplayer")
                }
            }
            .padding(115)
            
            Button(action: {
                AudioManager.shared.play(.buttonClick)
                appCoordinator.goTo(.helperScreen(.dishBook))
            }, label: {
                ZStack {
                    if let isNewDishEntry = UserDefaultsManager.shared.getIsNewDishSaved(), isNewDishEntry {
                        RotatingShineView()
                            .frame(width: 170)
                    }
                    
                    Image("dish_book")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 86, height: 110)
                        .rotationEffect(Angle(degrees: -5))
                }
            }).frame(width: 195, height: 195)
                .offset(x: -450, y: 310)
            
            InfoOverlayView(isPresented: $isShowingMultiplayerAlert, type: .multiplayerImageCreationNotSupported)
        }
        .onAppear {
            BGMManager.shared.play(track: .supermarket)
        }
    }
}

#Preview {
    StartingPageView()
        .environmentObject(AppCoordinator())
}
