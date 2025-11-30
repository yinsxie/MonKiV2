//
//  MoneyBreakView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 30/11/25.
//

import SwiftUI

struct MoneyBreakView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @StateObject var matchManager = MatchManager()
    @State var viewModel: BudgetSharingViewModel
    
    var body: some View {
        ZStack {
            Image("background_multi_share_budget")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(edges: .all)
            
            VStack {
                ZStack(alignment: .top) {
                    //TODO: maapkeun blm saya implement yg ease out "20 = 10 10"
                    Image("money_break")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 1118, height: 171)
                        .offset(y: 130)
                    
                    //TODO: maapkeun blm saya implement animasi tangannya masuk
                    Image("monki_hand")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 644)
                        .rotationEffect(.degrees(180))
                }
                .background(GeometryReader { geo in
                    Color.clear.onAppear {
                        viewModel.breakerFrame = geo.frame(in: .named("BudgetSpace"))
                    }
                })
                
                Spacer()
            }
            .ignoresSafeArea(edges: .top)
            .offset(y: -100)
            
            VStack {
                Spacer()
                HStack {
                    // MARK: - Host Zone (Kiri)
                    ZStack {
                        Image("share_budget_area_2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 444)
                        
                        // Component Profile + Wallet
                        PlayerStatsView(
                            playerName: "Kamu",
                            amount: viewModel.hostTotal,
                            isReady: matchManager.isLocalPlayerReady,
                            isGuest: false
                        )
                        .offset(x: 70, y: 100)
                    }
                    .offset(x: -50)
                    .background(GeometryReader { geo in
                        Color.clear.onAppear {
                            viewModel.hostZoneFrame = geo.frame(in: .named("BudgetSpace"))
                        }
                    })
                    
                    // MARK: - Center Button
                    // TODO: state disable (ketika drop zone hostnya blm ada uang), otherwise state active, kalau diklik pas active, change to loading state, textnya "Tunggun teman", iconnya "icon_loading_white"
                    MultiStateButton(text: "lanjut", state: .disabled, action: {})
                        .offset(y: -30)
                    
                    // MARK: - Guest Zone (Kanan)
                    ZStack {
                        Image("share_budget_area_1")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 444)
                        
                        // TODO: ganti ke username temen
                        PlayerStatsView(
                            playerName: "Kamu",
                            amount: viewModel.guestTotal,
                            isReady: false,
                            isGuest: true
                        )
                        .offset(x: -70, y: 100)
                    }
                    .offset(x: 50)
                    .background(GeometryReader { geo in
                        Color.clear.onAppear {
                            viewModel.guestZoneFrame = geo.frame(in: .named("BudgetSpace"))
                        }
                    })
                }
                .offset(y: 100)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

// MARK: - Reusable Component
struct PlayerStatsView: View {
    let playerName: String
    let amount: Int
    let isReady: Bool
    let isGuest: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            if isGuest {
                profileContent
                walletContent
            } else {
                walletContent
                profileContent
            }
        }
    }
    
    // Bagian Wallet (Dompet & Koin)
    @ViewBuilder
    var walletContent: some View {
        ZStack(alignment: .bottom) {
            Image("Wallet")
                .resizable()
                .scaledToFit()
                .frame(width: 292)
            
            HStack(spacing: 11) {
                Image("coin")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 40)
                
                Text("\(amount)")
                    .font(.fredokaMedium(size: 36, relativeTo: .title))
            }
            .padding(.vertical)
            .padding(.horizontal, 25)
            .background(
                RoundedRectangle(cornerRadius: 60)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 60)
                    .stroke(ColorPalette.neutral300, lineWidth: 6.22)
            )
            .offset(y: -185)
        }
    }
    
    // Bagian Profile (Avatar, Nama, Status)
    @ViewBuilder
    var profileContent: some View {
        HStack(spacing: 10) {
            //TODO: ganti ke avatar temen (untuk guest)
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 64, height: 64)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(playerName)
                    .font(.fredokaSemiBold(size: 24))
                    .foregroundStyle(ColorPalette.playerName)
                
                if isReady {
                    Text("Siap")
                        .font(.fredokaMedium(size: 12))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(ColorPalette.greenMoney)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
        }
        .padding(4)
        .padding(.trailing, 20)
        .background(
            Capsule()
                .fill(Color.white)
        )
        .offset(y: -20)
    }
}

struct MoneyBreakView_Previews: PreviewProvider {
    static var previews: some View {
        MoneyBreakView(viewModel: BudgetSharingViewModel(parent: PlayViewModel(gameMode: .multiplayer)))
            .environmentObject(AppCoordinator())
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
