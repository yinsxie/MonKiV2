//
//  JoinRoomView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 30/11/25.
//

import SwiftUI

struct JoinRoomView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    let inputOptions = ["🍎", "🍌", "🍇", "🍉", "🍒", "🍓", "🍍"]
    
    @Binding var roomCode: [String]
    
    @State var isShowTutorial: Bool = true
    
    var isCodeFull: Bool {
        return roomCode.count == 4
    }
    
    var isRemoveActive: Bool {
        return !roomCode.isEmpty
    }
    
    var onReturnButtonTapped: (() -> Void)?
    var onJoinButtonTapped: (() -> Void)?
    var onCancelJoinButtonTapped: (() -> Void)?
    
    @State var isJoinLoading: Bool = false
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(edges: .all)
            
            decorationSection
            
            VStack {
                headerSection
                Spacer()
            }
            
            contentSection
            
            GameCodePopupView(isShowing: $isShowTutorial)
                .opacity(isShowTutorial ? 1 : 0)
        }
        .onAppear {
            withAnimation {
                isShowTutorial = true
            }
            roomCode.removeAll()
        }
    }
}

// MARK: - View Builders & Sections
extension JoinRoomView {
    private var decorationSection: some View {
        ZStack(alignment: .bottom) {
            Image("monki_head_multi")
                .resizable()
                .scaledToFit()
                .frame(width: 939, height: 563)
                .ignoresSafeArea(edges: .all)
            
            MultiStateButton(
                text: isJoinLoading ? "Batal..." : "Main",
                state: isJoinLoading || isCodeFull ? .active : .disabled,
                action: {
                    if isJoinLoading {
                        // Cancel join action
                        isJoinLoading = false
                        onCancelJoinButtonTapped?()
                    }
                    else {
                        isJoinLoading = true
                        onJoinButtonTapped?()
                    }
                }
            )
            .offset(y: -230)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .offset(y: 150)
    }
    
    private var headerSection: some View {
        HStack {
            ReturnButton {
                onReturnButtonTapped?()
                isShowTutorial = true
            }
            //            HoldButton(type: .close, size: 122, strokeWidth: 10, onComplete: {
            //                onReturnButtonTapped?()
            //            })
            .accessibilityLabel("Kembali ke halaman sebelumnya")
            .padding(.leading, 48)
            .padding(.top, 48)
            Spacer()
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .center, spacing: 0) {
            titleArea
                .padding(.bottom, 42)
            
            codeDisplayArea
                .padding(.bottom, 130)
            
            inputKeypadArea
            
            Spacer()
        }
        .padding(.top, 150)
    }
    
    private var titleArea: some View {
        HStack(alignment: .top, spacing: 0) {
            Text("Masukkan Kode Permainan")
                .font(.fredokaSemiBold(size: 48))
                .foregroundStyle(ColorPalette.playWithFriendTitle)
            
            Image("icon_multi_info")
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .frame(width: 44, height: 44) // biar menuhin standar HIG (?)
                .contentShape(Rectangle())
                .onTapGesture {
                    isShowTutorial = true
                }
        }
    }
    
    private var codeDisplayArea: some View {
        HStack(spacing: 24) {
            ForEach(0..<4) { index in
                ZStack {
                    RoundedRectangle(cornerRadius: 48)
                        .frame(width: 180, height: 180)
                        .foregroundStyle(ColorPalette.codeBoxOuterBackground)
                    
                    RoundedRectangle(cornerRadius: 48)
                        .frame(width: 156, height: 156)
                        .foregroundStyle(Color.white)
                    
                    if index < roomCode.count {
                        Text(roomCode[index])
                            .font(.system(size: 60))
                            .transition(.scale)
                    }
                }
            }
            
            IconButton(
                iconName: isRemoveActive ? "remove_button_active" : "remove_button_disable",
                size: 92,
                action: {
                    if isRemoveActive {
                        withAnimation(.spring()) {
                            roomCode.removeAll()
                        }
                    }
                }
            )
            
            //                Image(isRemoveActive ? "remove_button_active" : "remove_button_disable")
            //                    .resizable()
            //                    .scaledToFit()
            //                    .frame(width: 92, height: 92)
            //                    .onTapGesture {
            //                        if isRemoveActive {
            //                            withAnimation(.spring()) {
            //                                roomCode.removeAll()
            //                            }
            //                        }
            //                    }
        }
    }
    
    private var inputKeypadArea: some View {
        HStack(spacing: 16) {
            ForEach(inputOptions, id: \.self) { fruit in
                Button {
                    if roomCode.count < 4 {
                        withAnimation(.spring()) {
                            roomCode.append(fruit)
                        }
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 48)
                            .frame(width: 140, height: 140)
                            .foregroundStyle(ColorPalette.choiceCodeBoxOuterBackground)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                        
                        RoundedRectangle(cornerRadius: 48)
                            .frame(width: 116, height: 116)
                            .foregroundStyle(ColorPalette.choiceCodeBoxInnerBackground)
                        
                        Text(fruit)
                            .font(.system(size: 60))
                    }
                }
            }
        }
    }
}
