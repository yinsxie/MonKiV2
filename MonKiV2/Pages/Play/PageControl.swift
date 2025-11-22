//
//  PageControl.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 21/11/25.
//

import SwiftUI

struct PageControl: View {
    @Binding var currentPageIndex: Int?
    let pageCount: Int
    @Namespace private var animationNamespace
    
    // MARK: - DEFINED CONSTANTS
    private let itemSize: CGFloat = 60
    private let containerPadding: CGFloat = 4
    private let iconInnerPadding: CGFloat = 16
    private let cornerRadius: CGFloat = 24
    
    // MARK: - CONFIGURATION
    private func getIconAssets(for index: Int) -> (active: String, inactive: String)? {
        switch index {
        case 0:
            return ("Icon_atm_active", "Icon_atm_inactive")
        case 1:
            return ("Icon_shelf_1_active", "Icon_shelf_1_inactive")
        case 5:
            return ("Icon_dish_active", "Icon_dish_inactive")
        default:
            return nil
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<pageCount, id: \.self) { index in
                let isActive = (currentPageIndex ?? 0) == index
                
                iconView(for: index, isActive: isActive)
                    .frame(width: itemSize, height: itemSize)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        animateToIndex(index)
                    }
            }
        }
        .padding(containerPadding)
        .background {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.white.opacity(0.26))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.white.opacity(0.25), lineWidth: 4)
                        .shadow(color: Color.white.opacity(0.25), radius: 4, x: 4, y: 4)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                )
        }
        .fixedSize()
        
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let locationX = value.location.x - containerPadding
                    let newIndex = Int(locationX / itemSize)
                    
                    if newIndex >= 0 && newIndex < pageCount {
                        if currentPageIndex != newIndex {
                            animateToIndex(newIndex)
                        }
                    }
                }
        )
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private func iconView(for index: Int, isActive: Bool) -> some View {
        if let assets = getIconAssets(for: index) {
            Image(isActive ? assets.active : assets.inactive)
                .resizable()
                .scaledToFit()
                .padding(iconInnerPadding)
                .background {
                    if isActive {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.white)
                            .frame(width: itemSize, height: itemSize)
                            .matchedGeometryEffect(id: "ActiveTab", in: animationNamespace)
                            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                    }
                }
                .transition(.scale.animation(.easeInOut(duration: 0.2)))
            
        } else {
            RoundedRectangle(cornerRadius: 4)
                .fill(isActive ? Color.gray : Color.white.opacity(0.3))
                .frame(width: 20, height: 20)
        }
    }
    
    private func animateToIndex(_ index: Int) {
        withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.75)) {
            currentPageIndex = index
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

#Preview {
    ZStack {
        Color.gray
        PageControl(currentPageIndex: .constant(0), pageCount: 6)
    }
}
