//
//  BudgetSharingView.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 26/11/25.
//
import SwiftUI

struct BudgetSharingView: View {
    @State var viewModel: BudgetSharingViewModel
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.opacity(0.85).ignoresSafeArea()
                
                // 1. Zones & Breaker
                VStack {
                    moneyBreaker
                    
                    Spacer()
                    
                    HStack(spacing: 0) {
                        hostZone
                        Spacer()
                        guestZone
                    }
                }
                
                // 2. Money Items
                moneyLayer(geo: geo)
                
                // 3. Ready Button
                VStack {
                    Spacer()
                    readyButton
                }
            }
            .coordinateSpace(name: "BudgetSpace") // Critical for frame matching
            .onAppear {
                viewModel.totalContainerSize = geo.size
            }
        }
    }
    
    // MARK: - Components
    
    private var hostZone: some View {
        VStack {
            Text(viewModel.amIHost ? "YOU (Host)" : "FRIEND (Host)")
                .font(.headline)
                .foregroundColor(.green)
            
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.green, style: StrokeStyle(lineWidth: 4, dash: [10]))
                .background(Color.green.opacity(0.1))
                // CAPTURE FRAME
                .background(GeometryReader { geo in
                    Color.clear.onAppear {
                        viewModel.hostZoneFrame = geo.frame(in: .named("BudgetSpace"))
                    }
                })
                .overlay(
                    Text("Total: \(viewModel.hostTotal)")
                        .font(.title.bold())
                        .foregroundColor(.white)
                )
        }
        .padding()
        .frame(maxWidth: 300, maxHeight: 400)
    }
    
    private var guestZone: some View {
        VStack {
            Text(!viewModel.amIHost ? "YOU (Guest)" : "FRIEND (Guest)")
                .font(.headline)
                .foregroundColor(.red)
            
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.red, style: StrokeStyle(lineWidth: 4, dash: [10]))
                .background(Color.red.opacity(0.1))
                // CAPTURE FRAME
                .background(GeometryReader { geo in
                    Color.clear.onAppear {
                        viewModel.guestZoneFrame = geo.frame(in: .named("BudgetSpace"))
                    }
                })
                .overlay(
                    Text("Total: \(viewModel.guestTotal)")
                        .font(.title.bold())
                        .foregroundColor(.white)
                )
        }
        .padding()
        .frame(maxWidth: 300, maxHeight: 400)
    }
    
    private var moneyBreaker: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 100, height: 100)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                Image(systemName: "scissors")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            // CAPTURE FRAME
            .background(GeometryReader { geo in
                Color.clear.onAppear {
                    viewModel.breakerFrame = geo.frame(in: .named("BudgetSpace"))
                }
            })
            Text("Drop to Break")
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding(.top, 40)
    }
    
    private func moneyLayer(geo: GeometryProxy) -> some View {
        ForEach(viewModel.sharedMoneys) { money in
            Image(money.currency.imageAssetPath)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 50)
                .rotationEffect(.degrees(money.rotation))
                .scaleEffect(money.isBeingDragged ? 1.2 : 1.0)
                .opacity(shouldDim(money) ? 0.6 : 1.0)
                .overlay(borderOverlay(for: money))
                .position(
                    x: money.position.x * geo.size.width,
                    y: money.position.y * geo.size.height
                )
                .gesture(dragGesture(for: money, geo: geo))
        }
    }
    
    private var readyButton: some View {
        VStack {
            if viewModel.isRemoteReady {
                Text("Friend is Ready!")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding(.bottom, 5)
            }
            
            Button(action: { viewModel.toggleReady() }) {
                Text(viewModel.isLocalReady ? "WAITING..." : "READY")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(
                        Capsule().fill(
                            viewModel.isLocalReady ? Color.gray :
                                (viewModel.isDistributionComplete ? Color.blue : Color.gray.opacity(0.5))
                        )
                    )
            }
            .disabled(!viewModel.isDistributionComplete)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Helpers
    
    private func borderOverlay(for money: SharedMoney) -> some View {
        RoundedRectangle(cornerRadius: 5)
            .stroke(
                money.owner == .host ? Color.green :
                money.owner == .guest ? Color.red : Color.clear,
                lineWidth: 3
            )
            .rotationEffect(.degrees(money.rotation))
    }
    
    private func shouldDim(_ money: SharedMoney) -> Bool {
        // Dim if locked by OTHER person
        guard let locker = money.lockedBy else { return false }
        return locker != viewModel.myRole
    }
    
    private func dragGesture(for money: SharedMoney, geo: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if !canDrag(money) { return }
                
                // Trigger lock on first drag movement
                if money.lockedBy == nil {
                    viewModel.onDragStart(id: money.id)
                }
                
                viewModel.onDragChanged(
                    id: money.id,
                    location: value.location
                )
            }
            .onEnded { value in
                if !canDrag(money) { return }
                
                viewModel.onDragEnded(
                    id: money.id,
                    location: value.location
                )
            }
    }
    
    private func canDrag(_ money: SharedMoney) -> Bool {
        if viewModel.isLocalReady { return false }
        
        // Locked by someone else?
        if let locker = money.lockedBy, locker != viewModel.myRole {
            return false
        }
        
        // Zone Restriction (Host can't drag Guest's items)
        if viewModel.amIHost { return money.owner != .guest }
        else { return money.owner != .host }
    }
}
