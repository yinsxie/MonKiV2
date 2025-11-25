//
//  MultiplayerLobbyView.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 24/11/25.
//

import SwiftUI
import GameKit

struct MultiplayerLobbyView: View {
    @StateObject var matchManager = MatchManager()
    @ObservedObject var gcManager = GameCenterManager.shared
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    @State private var showingCodeOptions = false
    @State private var roomCode: [String] = [] // Stores Emojis ["🍎", "🍌"]
    @State private var isHosting = false
    @State private var isJoining = false // NEW: Track if we are in "Input Mode"
    
    // The "Keyboard" Options
    let fruitOptions = ["🍎", "🍌", "🍇", "🍉"]
    
    var body: some View {
        ZStack {
            // Global Background
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            // Dynamic Content based on Match State
            switch matchManager.matchState {
                
            case .idle:
                if !showingCodeOptions {
                    mainMenuButtons
                } else {
                    codeEntryInterface
                }
                
            case .searching:
                searchingView
                
            case .connected:
                connectedView
                
            case .playing:
                VStack {
                    ProgressView()
                    Text("Entering Supermarket...")
                        .foregroundColor(.white)
                        .font(.headline)
                }
            }
        }
        .onAppear {
            if !gcManager.isAuthenticated {
                gcManager.authenticateUser()
            }
        }
        .onChange(of: matchManager.matchState) { _, newState in
           if newState == .playing {
               print("🚀 Game Started! Navigating to PlayView...")
               
               appCoordinator.changeRootAnimate(root: .play(.multiplayer(matchManager)))
           }
       }
    }
    
    // MARK: - SUBVIEWS
    
    // 1. MAIN MENU (Full Screen, iPhone Optimized)
    var mainMenuButtons: some View {
        GeometryReader { geo in
            VStack(spacing: 20) {
                
                // Title
                HStack(spacing: 15) {
                    Image(systemName: "cart.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    Text("Supermarket Race")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(.blue)
                }
                .padding(.top, 10)
                
                // Buttons container
                HStack(spacing: 30) {
                    // Button A: Random
                    Button(action: {
                        matchManager.startMatchmaking(withCode: 0)
                    }) {
                        VStack(spacing: 15) {
                            Image(systemName: "globe")
                                .font(.system(size: 50))
                            Text("Random\nPlayer")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.blue)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                    }
                    
                    Text("OR")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .fontWeight(.bold)
                    
                    // Button B: Play with Friend
                    Button(action: {
                        withAnimation { showingCodeOptions = true }
                    }) {
                        VStack(spacing: 15) {
                            Text("🍎🍌")
                                .font(.system(size: 50))
                            Text("Play with\nFriend")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.green)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
                .frame(height: geo.size.height * 0.6)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
    
    // 2. FRUIT CODE INTERFACE (Host/Join Selection + Keypad)
    var codeEntryInterface: some View {
        VStack(spacing: 10) {
            
            // Header with Back Button
            HStack {
                Button(action: {
                    withAnimation {
                        if isJoining {
                            // If in keypad mode, go back to selection
                            isJoining = false
                            roomCode = []
                        } else {
                            // If in selection mode, go back to main menu
                            showingCodeOptions = false
                            isHosting = false
                        }
                    }
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.title2)
                        Text(isJoining ? "Back to Choice" : "Back to Menu") // Dynamic Text
                            .font(.headline)
                    }
                    .foregroundColor(.gray)
                    .padding()
                }
                Spacer()
            }
            
            Spacer()
            
            if !isHosting {
                // PHASE A: Host or Join SELECTION
                if !isJoining {
                    VStack(spacing: 20) {
                        Text("Do you want to Host or Join?")
                            .font(.title3.bold())
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 30) {
                            // Host Button
                            Button {
                                generateRandomFruitCode()
                                isHosting = true
                                startMatch()
                            } label: {
                                VStack(spacing: 10) {
                                    Image(systemName: "house.fill").font(.system(size: 40))
                                    Text("Create Room")
                                        .font(.headline)
                                }
                                .frame(width: 160, height: 140)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.blue, lineWidth: 3)
                                )
                            }
                            
                            // Join Button (Now activates the Keypad)
                            Button {
                                withAnimation {
                                    isJoining = true
                                }
                            } label: {
                                VStack(spacing: 10) {
                                    Image(systemName: "person.2.fill").font(.system(size: 40))
                                    Text("Join Room")
                                        .font(.headline)
                                }
                                .frame(width: 160, height: 140)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.green, lineWidth: 3)
                                )
                            }
                        }
                    }
                }
                
                // PHASE B: Keypad Input (Only visible if isJoining is true)
                if isJoining {
                    VStack(spacing: 15) {
                        Text("Enter the code:")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        // Display Selected Fruits
                        HStack(spacing: 15) {
                            ForEach(0..<4) { index in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                                        )
                                    
                                    if index < roomCode.count {
                                        Text(roomCode[index])
                                            .font(.system(size: 40))
                                            .transition(.scale)
                                    }
                                }
                            }
                        }
                        
                        // Fruit Buttons
                        if roomCode.count < 4 {
                            HStack(spacing: 20) {
                                ForEach(fruitOptions, id: \.self) { fruit in
                                    Button {
                                        withAnimation(.spring()) {
                                            roomCode.append(fruit)
                                        }
                                    } label: {
                                        Text(fruit)
                                            .font(.system(size: 50))
                                            .frame(width: 70, height: 70)
                                            .background(Color.white)
                                            .cornerRadius(20)
                                            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 3)
                                    }
                                }
                            }
                        } else {
                            // Action Buttons (Clear / Connect)
                            HStack(spacing: 20) {
                                Button(action: {
                                    withAnimation { roomCode = [] }
                                }) {
                                    HStack {
                                        Image(systemName: "trash.fill")
                                        Text("Clear")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 120)
                                    .background(Color.red)
                                    .cornerRadius(15)
                                }
                                
                                Button(action: {
                                    startMatch()
                                }) {
                                    HStack {
                                        Image(systemName: "link")
                                        Text("Connect")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 120)
                                    .background(Color.green)
                                    .cornerRadius(15)
                                }
                            }
                        }
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            
            Spacer()
        }
    }
    
    // 3. SEARCHING VIEW
    var searchingView: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                if isHosting {
                    Text("Your Room Code:")
                        .font(.title3)
                        .foregroundColor(.gray)
                    
                    // Show the fruits
                    HStack(spacing: 15) {
                        ForEach(roomCode, id: \.self) { fruit in
                            Text(fruit)
                                .font(.system(size: 60))
                                .frame(width: 80, height: 80)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.blue, lineWidth: 3)
                                )
                        }
                    }
                    
                    Text("Tell your friend to tap these fruits!")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    ProgressView()
                        .scaleEffect(1.2)
                    
                } else {
                    // Random Match Searching UI
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(2)
                        
                        Text("Searching...")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
                
                // CANCEL BUTTON
                Button(action: {
                    matchManager.cancelMatchmaking()
                    isHosting = false
                    isJoining = false // Reset joining state
                    roomCode = []
                }) {
                    Text("Cancel Search")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 180)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(15)
                }
                .padding(.top, 20)
            }
        }
    }
    
    // 4. CONNECTED VIEW (The Handshake)
    var connectedView: some View {
        VStack(spacing: 20) {
            Text("Friend Found!")
                .font(.largeTitle.weight(.heavy))
                .foregroundColor(.green)
            
            HStack(spacing: 40) { // Reduced spacing for iPhone
                // YOU
                VStack(spacing: 10) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                    
                    Text("You")
                        .font(.title3.bold())
                    
                    if matchManager.isLocalPlayerReady {
                        Text("READY")
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
                
                Text("VS")
                    .font(.system(size: 50, weight: .black))
                    .foregroundColor(.orange)
                    .italic()
                
                // OPPONENT
                VStack(spacing: 10) {
                    if let avatar = matchManager.otherPlayerAvatar {
                        avatar
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                    }
                    
                    Text(matchManager.otherPlayerName)
                        .font(.title3.bold())
                        .lineLimit(1)
                        .frame(maxWidth: 100)
                    
                    if matchManager.isRemotePlayerReady {
                        Text("READY")
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    } else {
                        Text("Connecting...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.vertical, 10)
            
            // ACTION AREA
            if !matchManager.isLocalPlayerReady {
                Button(action: {
                    matchManager.sendReadySignal()
                }) {
                    Text("I'M READY!")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220)
                        .background(Color.blue)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
            } else {
                if !matchManager.isRemotePlayerReady {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text("Waiting for friend...")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                } else {
                    Text("Starting Game...")
                        .font(.title2.bold())
                        .foregroundColor(.green)
                }
            }
        }
    }
    
    // MARK: - LOGIC HELPERS
    
    func generateRandomFruitCode() {
        roomCode = []
        for _ in 0..<4 {
            if let randomFruit = fruitOptions.randomElement() {
                roomCode.append(randomFruit)
            }
        }
    }
    
    func startMatch() {
        var codeString = ""
        for fruit in roomCode {
            if fruit == "🍎" { codeString += "1" }
            else if fruit == "🍌" { codeString += "2" }
            else if fruit == "🍇" { codeString += "3" }
            else if fruit == "🍉" { codeString += "4" }
        }
        
        if let codeInt = Int(codeString) {
            matchManager.startMatchmaking(withCode: codeInt)
        }
    }
}
