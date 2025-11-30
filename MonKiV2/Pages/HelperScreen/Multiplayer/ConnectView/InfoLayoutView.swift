//
//  InfoLayoutView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 30/11/25.
//

import SwiftUI

struct GameCodePopupView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
            
            HStack(spacing: 0) {
                IllustrationView()
                InstructionListView()
            }
            .frame(width: 1064, height: 400)
            .padding(48)
            .background(ColorPalette.infoBackground)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white, lineWidth: 24)
            )
            .padding(48)
        }
    }
}

// MARK: - Subviews
private struct IllustrationView: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("info_layout_code")
                .resizable()
                .scaledToFit()
                .frame(width: 574, height: 409)
            
            Image("monki_info")
                .resizable()
                .scaledToFit()
                .frame(width: 214, height: 307)
                .offset(x: -20, y: 50)
        }
        .frame(width: 574, height: 409)
        .padding(.trailing, 36)
    }
}

private struct InstructionListView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .top, spacing: 10) {
                CircleNumberView(number: 1, size: 32, fontSize: 16, innerpadding: 4)
                Text("Lihat layar temanmu yang membuat permainan")
                    .font(.fredokaSemiBold(size: 28))
                    .foregroundStyle(ColorPalette.playWithFriendTitle)
                
            }
            
            HStack(alignment: .top, spacing: 10) {
                CircleNumberView(number: 2, size: 32, fontSize: 16, innerpadding: 4)
                Text("Masukkan keempat simbol yang sama sesuai urutan")
                    .font(.fredokaSemiBold(size: 28))
                    .foregroundStyle(ColorPalette.playWithFriendTitle)
                
            }
            
            HStack(alignment: .top, spacing: 10) {
                CircleNumberView(number: 3, size: 32, fontSize: 16, innerpadding: 4)
                Text("Tunggu terhubung hingga bisa memulai permainan")
                    .font(.fredokaSemiBold(size: 28))
                    .foregroundStyle(ColorPalette.playWithFriendTitle)
            }
        }
    }
}

// MARK: - Preview
struct GameCodePopupView_Previews: PreviewProvider {
    static var previews: some View {
        GameCodePopupView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
