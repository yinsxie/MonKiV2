//
//  PickChefView.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 22/11/25.
//
import SwiftUI

enum ChefType: String, CaseIterable, Identifiable {
    case rice
    case pasta
    case bread
    
    var id: String { rawValue }
    
    var activeImage: String {
        switch self {
        case .rice: return "chef_monki_rice"
        case .pasta: return "chef_monki_pasta"
        case .bread: return "chef_monki_bread"
        }
    }
    
    var baseIngredientName: String {
        switch self {
        case .rice: return "Rice"
        case .pasta: return "Pasta"
        case .bread: return "Bread"
        }
    }
    
    var isUnlocked: Bool {
        switch self {
        case .rice: return true
        case .pasta, .bread: return false
        }
    }
}

struct PickChefView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    var body: some View {
        ZStack {
            // Background
            //            GeometryReader { geo in
            //                let backgroundSplitHeight = geo.size.height * (753 / 1024.0)
            //
            //                VStack(spacing: 0) {
            //                    Color(hex: "#27A8DF").opacity(0.5)
            //                        .frame(height: backgroundSplitHeight)
            //                    Color(hex: "#85DCFA").opacity(0.5)
            //                }
            //                .ignoresSafeArea()
            //            }
            
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(edges: .all)
            
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
                ForEach(ChefType.allCases) { chef in
                    chefButton(for: chef)
                }
            }
            .padding(.top, 170)
        }
        .ignoresSafeArea(edges: .all)
    }
}

extension PickChefView {
    @ViewBuilder
    private func chefButton(for chef: ChefType) -> some View {
        Button(action: {
            AudioManager.shared.play(.buttonClick)
            appCoordinator.goTo(.play(.singlePlayer(chef: chef)))
        }, label: {
            VStack(alignment: .leading) {
                Image(chef.activeImage)
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
