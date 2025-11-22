//
//  PickChefView.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 22/11/25.
//
import SwiftUI

struct PickChefView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    var body: some View {
        ZStack {
            // Background
            GeometryReader { geo in
                let backgroundSplitHeight = geo.size.height * (753 / 1024.0)
                
                VStack(spacing: 0) {
                    Color(hex: "#27A8DF").opacity(0.5)
                        .frame(height: backgroundSplitHeight)
                    Color(hex: "#85DCFA").opacity(0.5)
                }
                .ignoresSafeArea()
            }
            
            // Return Button
            VStack {
                HStack {
                    ReturnButton(action: {
                        appCoordinator.popLast()
                    })
                    .padding(.leading, 82)
                    .padding(.top, 82)
                    Spacer()
                }
                Spacer()
            }
            
            HStack(spacing: 45) {
                chefButton
                chefButton
                    .disabled(true)
                chefButton
                    .disabled(true)
            }
            .padding(.top, 130)
        }
        .ignoresSafeArea(edges: .all)
    }
}

extension PickChefView {
    @ViewBuilder
    private var chefButton: some View {
        Button(action: {
            AudioManager.shared.play(.buttonClick)
                appCoordinator.goTo(.play(.play))
        }, label: {
            VStack(alignment: .leading) {
                Image("cashier_monki")
                    .resizable()
                    .scaledToFit()
                Spacer()
            }
            .frame(width: 314.24017, height: 450)
            .background(Color(red: 0.85, green: 0.85, blue: 0.85))
        })
    }
}

#Preview {
    PickChefView()
        .environmentObject(AppCoordinator())
}
