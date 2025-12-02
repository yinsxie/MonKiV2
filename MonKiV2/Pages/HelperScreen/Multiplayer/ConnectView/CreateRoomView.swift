//
//  CreateRoomView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 29/11/25.
//

import SwiftUI

struct CreateRoomView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    let fruitOptions = ["🍎", "🍌", "🍇", "🍉"]

    @Binding var roomCode: [String]
    var onBackButtonPressed: (() -> Void)?

    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(edges: .all)
            
            VStack {
                headerSection
                Spacer()
            }
            
            VStack(spacing: 0) {
                Spacer()
                
                titleSection
                    .padding(.bottom, 32)
                
                codeDisplaySection
                
                bottomDecorationSection
                    .offset(y: 60)
            }
            // .background()
        }
    }
}

// MARK: - View Sections
extension CreateRoomView {
    private var headerSection: some View {
        HStack {
            ReturnButton {
                onBackButtonPressed?()
            }
//            HoldButton(type: .close, size: 122, strokeWidth: 10, onComplete: {
//                appCoordinator.popLast()
//            })
            .accessibilityLabel("Kembali ke halaman sebelumnya")
            .padding(.leading, 48)
            .padding(.top, 48)
            Spacer()
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Kode Permainan")
                .font(.fredokaSemiBold(size: 48))
                .foregroundStyle(ColorPalette.playWithFriendTitle)
            
            Text("Tunjukkan simbol ini ke teman bermainmu!")
                .font(.fredokaSemiBold(size: 32))
                .foregroundStyle(ColorPalette.playWithFriendTitle)
        }
    }
    
    private var codeDisplaySection: some View {
        HStack(spacing: 24) {
                ForEach(Array(roomCode.enumerated()), id: \.offset) { index, fruit in
                    DisplayCodeBox(fruit: fruit)
            }
        }
    }
    
    private var bottomDecorationSection: some View {
        ZStack(alignment: .bottom) {
            Image("monki_head_multi")
                .resizable()
                .scaledToFit()
                .frame(width: 939, height: 563)
                .ignoresSafeArea(edges: .all)
            
            MultiStateButton(
                text: "Tunggu Teman",
                iconName: "icon_loading_white",
                state: .loading,
                action: { }
            )
            .offset(y: -110)
        }
    }
}

// MARK: - Reusable Component
struct DisplayCodeBox: View {
    let fruit: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 48)
                .frame(width: 180, height: 180)
                .foregroundStyle(ColorPalette.codeBoxOuterBackground)
            
            RoundedRectangle(cornerRadius: 48)
                .frame(width: 156, height: 156)
                .foregroundStyle(Color.white)
            
            Text(fruit)
                .font(.system(size: 60))
        }
    }
}
