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
                    .accessibilityLabel("Kembali ke halaman sebelumnya")
                    .padding(.leading, 82)
                    .padding(.top, 82)
                    Spacer()
                }
                Spacer()
            }
            
            HStack(spacing: 45) {
                chefButton
                disableChefButton
                    .disabled(true)
                disableChefButton
                    .disabled(true)
            }
            .padding(.top, 170)
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
                Image("chef_monki_full")
                    .resizable()
                    .scaledToFit()
                Spacer()
            }
            .frame(width: 314, height: 508)
        })
    }
    
    @ViewBuilder
    private var disableChefButton: some View {
        Button(action: {
            AudioManager.shared.play(.buttonClick)
        }, label: {
            VStack(alignment: .leading) {
                Image("chef_monki_disable")
                    .resizable()
                    .scaledToFit()
                Spacer()
            }
            .frame(width: 314, height: 508)
        })
    }
}

#Preview {
    PickChefView()
        .environmentObject(AppCoordinator())
}
