//
//  ImageCreationFallbackView.swift
//  MonKiV2
//
//  Created by William on 02/12/25.
//

import SwiftUI
import Combine

enum InfoOverlayType {
    case multiplayerConnectionLost
    case multiplayerImageCreationNotSupported
    case createDishImageCreationNotSupported
}

struct InfoOverlayView: View {
    
    @Binding var isPresented: Bool
    let type: InfoOverlayType
    var onCTAButtonCompletion: (() -> Void)?
    
    @State private var countdown: Int = 5
    @State private var timer: AnyCancellable?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }
            
            HStack(spacing: type == .multiplayerConnectionLost ? 64 : 0) {
                illustrationView
                messageView
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
            
            CTAButtonView
                .offset(y: 250)
        }
        .opacity(isPresented ? 1 : 0)
        .onAppear {
            if type == .multiplayerConnectionLost {
                startCountdownTimer()
            }
        }
        .onDisappear {
            timer?.cancel()
        }
    }
    
    @ViewBuilder
    var CTAButtonView: some View {
        var CTAText: String {
            switch type {
            case .multiplayerConnectionLost:
                return "Keluar"
            case .createDishImageCreationNotSupported, .multiplayerImageCreationNotSupported:
                return "Kembali"
            }
        }
        
        MultiStateButton(text: CTAText, state: .active) {
            if type == .multiplayerConnectionLost {
                onCTAButtonCompletion?()
            } else {
                withAnimation {
                    isPresented = false
                }
            }
        }
    }
    
    @ViewBuilder
    var illustrationView: some View {
        
        var imagePath: String {
            switch type {
            case .createDishImageCreationNotSupported:
                return "stand_monki_sad"
            case .multiplayerConnectionLost:
                return "chef_monki_sad_1"
            default:
                return ""
            }
        }
        
        var imageWidth: CGFloat? {
            switch type {
            case .createDishImageCreationNotSupported:
                return 470
            case .multiplayerConnectionLost:
                return 220.28
            default:
                return nil
            }
        }
        
        if type == .multiplayerImageCreationNotSupported {
            HStack(spacing: 20) {
                Image("chef_monki_sad_1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220.28)
                
                Image("chef_monki_sad_2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220.28)
            }
            .padding(.trailing, 36)
        }
        else {
            if !imagePath.isEmpty {
                Image(imagePath)
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageWidth)
            }
        }
    }
    
    @ViewBuilder
    var messageView: some View {
        
        var textTitle: String {
            switch type {
            case .createDishImageCreationNotSupported:
                return "Belum bisa masak..."
            case .multiplayerConnectionLost:
                return "Koneksi Hilang..."
            case .multiplayerImageCreationNotSupported:
                return "Belum bisa main bareng"
            }
        }
        
        var textSubtitle: String {
            switch type {
            case .createDishImageCreationNotSupported:
                return "Di iPad ini, kamu belum bisa lihat hasil masakan"
            case .multiplayerConnectionLost:
                return "Sepertinya koneksi internetmu lagi kurang bagus. Yuk coba cek dulu, ya!"
            case .multiplayerImageCreationNotSupported:
                return "Di iPad ini, kamu belum bisa main bareng temanmu"
            }
        }
        
        var isNeedGuidance: Bool {
            switch type {
            case .multiplayerConnectionLost:
                return false
            default:
                return true
            }
        }
        
        var textFooterGuidance: String {
            switch type {
            case .createDishImageCreationNotSupported:
                return "bisa masak"
            case .multiplayerImageCreationNotSupported:
                return "bisa main bareng"
            case .multiplayerConnectionLost:
                return ""
            }
        }
        
        VStack(alignment: .leading, spacing: 35) {
            VStack(alignment: .leading, spacing: 24) {
                Text(textTitle)
                    .font(.fredokaSemiBold(size: 42))
                    .foregroundStyle(ColorPalette.playWithFriendTitle)
                
                Text(textSubtitle)
                    .font(.fredokaRegular(size: 36))
                    .foregroundStyle(ColorPalette.playWithFriendTitle)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                if isNeedGuidance {
                    Text("Butuh **Apple Intelligence** untuk \(textFooterGuidance).")
                        .font(.fredokaRegular(size: 20))
                }
            }
            
            if type == .multiplayerConnectionLost {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("Keluar dalam ")
                    
                    Text("\(countdown)")
                        .font(.fredokaSemiBold(size: 48))
                    
                    Text(" detik...")
                }
                .font(.fredokaRegular(size: 20))
            }
            
            guidanceView
                .opacity(isNeedGuidance ? 1 : 0)
        }
        .foregroundStyle(ColorPalette.playWithFriendTitle)
    }
    @ViewBuilder
    var guidanceView: some View {
        HStack {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 40))
            
            Text("Buka **pengaturan** → **Apple Intelligence & Siri** → Hidupkan **Apple Intelligence**")
                .font(.fredokaRegular(size: 20))
        }
    }
    
    func startCountdownTimer() {
        countdown = 5
        timer?.cancel()
        
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if countdown > 0 {
                    countdown -= 1
                    print("Countdown: \(countdown)")
                } else {
                    handleTimerCompletion()
                }
            }
    }
    
    // Function to run when the timer hits zero
    func handleTimerCompletion() {
        // Stop the timer first
        timer?.cancel()
        timer = nil
        isPresented = false
        onCTAButtonCompletion?()
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack {
            InfoOverlayView(isPresented: .constant(true), type: .createDishImageCreationNotSupported)
            InfoOverlayView(isPresented: .constant(true), type:
                    .multiplayerConnectionLost)
            InfoOverlayView(isPresented: .constant(true), type: .multiplayerImageCreationNotSupported)
        }
    }
}
