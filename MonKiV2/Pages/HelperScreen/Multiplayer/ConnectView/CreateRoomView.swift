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
    
    private let fruitToNumberMap: [String: String] = [
        "🍎": "1", "🍌": "2", "🍇": "3", "🍉": "4"
    ]
    
    @State private var roomCode: [String] = []
    
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
                    .offset(y: 45)
            }
            // .background()
        }
        .onAppear {
            generateRandomFruitCode()
        }
    }
}

// MARK: - View Sections
extension CreateRoomView {
    private var headerSection: some View {
        HStack {
            HoldButton(type: .close, size: 122, strokeWidth: 10, onComplete: {
                appCoordinator.popLast()
            })
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
            if roomCode.isEmpty {
                ProgressView()
            } else {
                ForEach(roomCode, id: \.self) { fruit in
                    DisplayCodeBox(fruit: fruit)
                }
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

// MARK: - Logic & Helpers
extension CreateRoomView {
    
    func generateRandomFruitCode() {
        roomCode = []
        for _ in 0..<4 {
            if let randomFruit = fruitOptions.randomElement() {
                roomCode.append(randomFruit)
            }
        }
    }
    
    func getNumericCode() -> Int? {
        let codeString = roomCode.compactMap { fruitToNumberMap[$0] }.joined()
        return Int(codeString)
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

// MARK: - Preview
struct CreateRoomView_Previews: PreviewProvider {
    static var previews: some View {
        CreateRoomView()
            .environmentObject(AppCoordinator())
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
