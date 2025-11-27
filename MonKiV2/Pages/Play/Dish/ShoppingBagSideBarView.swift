//
//  ShoppingBagSideBarView.swift
//  MonKiV2
//
//  Created by William on 19/11/25.
//

import SwiftUI

// already had this
struct HeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// new key to measure the scroll container size
struct ContainerHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct ShoppingBagSideBarView: View {
    
    @Environment(CreateDishViewModel.self) var dishVM
    @Environment(DragManager.self) var dragManager
    @Environment(PlayViewModel.self) var playVM
    
    // measured receipt content height (from HeightKey)
    @State private var contentHeight: CGFloat = 0
    // measured scroll container height (from ContainerHeightKey)
    @State private var containerHeight: CGFloat = 0
    
    let sideBarWidth: CGFloat = 291
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // RECEIPT (behind)
            if dishVM.isBagTapped {
                receiptView
                    .padding(.horizontal, 20)
                    .transition(.move(edge: .bottom))
                    .animation(.spring(response: 0.25, dampingFraction: 0.8), value: dishVM.isBagTapped)
            }
            
            // BAG (fixed in front)
            VStack {
                Spacer()
                shoppingBagView
            }
            .zIndex(10)
        }
        .ignoresSafeArea()
        .frame(width: sideBarWidth)
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 40)
        .onChange(of: playVM.currentPageIndex) {
            // MARK: Change if turning on Debug IngredientsListView
            if playVM.getCurrentPage() == .createDish {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    toggleBag(to: true)
                }
            } else {
                toggleBag(to: false)
            }
        }
    }
    
    // MARK: - Receipt View
    var receiptView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                
                // dynamic red filler: uses measured heights
                Color.red
                    .frame(height: max(max(containerHeight - contentHeight, 0), 150))
                    .clipped()
                    .opacity(0)
                    .onHeaderCloseSwipe {
                        toggleBag(to: false)
                    }
                
                // receipt content container (measured by HeightKey)
                VStack(spacing: 0) {
                    
                    // --- HEADER AREA (Scrollable + Swipeable) ---
                    VStack(spacing: 0) {
                        // Top Paper Edge
                        Image("receipt_top")
                            .resizable()
                            .scaledToFill()
                            .offset(y: -22)
                        
                        // Logo + Barrier
                        VStack(spacing: 35) {
                            Image("receipt_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 114.66)
                            
                            Image("receipt_barrier")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 209.25)
                        }
                    }
                    .background(ColorPalette.overlayBackground)
                    .onHeaderCloseSwipe {
                        toggleBag(to: false)
                    }
                    
                    // --- LIST AREA (Normal Scroll) ---
                    VStack(spacing: 40) {
                        if dishVM.groceriesList.isEmpty {
                            Color.clear
                        }
                        ForEach(dishVM.groceriesList) { grocery in
                            GroceryDetailView(grocery: grocery)
                                .makeDraggable(
                                    item: DraggedItem(
                                        id: grocery.item.id,
                                        payload: .grocery(grocery.item),
                                        source: .createDishOverlay
                                    )
                                )
                                .opacity(
                                    dragManager.currentDraggedItem?.id == grocery.item.id &&
                                    grocery.quantity == 1 &&
                                    dragManager.currentDraggedItem?.source == .createDishOverlay
                                    ? 0 : 1
                                )
                        }
                        // keep some bottom breathing room
                        Spacer(minLength: 0)
                    }
                    .frame(minHeight: 350)
                    .padding(.top, 40)
                    .background(RoundedRectangle(cornerRadius: 12).fill(ColorPalette.neutral50))
                    .padding(.vertical)
                    .padding(.horizontal, 25)
                }
                .background(ColorPalette.overlayBackground)
                // measure the receipt content height
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(key: HeightKey.self, value: geo.size.height)
                    }
                )
                Image("receipt_top")
                    .resizable()
                    .scaledToFit()
                    .offset(y: 4)
                    .rotationEffect(.degrees(180))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 30)
            .padding(.bottom, 100)
        }
        // measure the visible ScrollView container height
        .background(
            GeometryReader { geo in
                Color.clear.preference(key: ContainerHeightKey.self, value: geo.size.height)
            }
        )
        // update the two measured heights when they change
        .onPreferenceChange(HeightKey.self) { newContentHeight in
            // contentHeight is the measured height of the receipt content only
            if abs(contentHeight - newContentHeight) > 0.5 {
                DispatchQueue.main.async {
                    contentHeight = newContentHeight
                }
            }
        }
        .onPreferenceChange(ContainerHeightKey.self) { newContainerHeight in
            if abs(containerHeight - newContainerHeight) > 0.5 {
                DispatchQueue.main.async {
                    containerHeight = newContainerHeight
                }
            }
        }
        .makeDropZone(type: .createDishOverlay)
    }
    
    // MARK: Bag button
    var shoppingBagView: some View {
        Image("plastic_bag")
            .resizable()
            .scaledToFit()
            .frame(width: sideBarWidth)
            .onComponentSwipe(
                open: { toggleBag(to: true) },
                close: { toggleBag(to: false) }
            )
            .onTapGesture {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    dishVM.isBagTapped.toggle()
                }
            }
        // keep bag visually overlapping the receipt: adjust if needed
            .padding(.bottom, -200)
            .frame(maxWidth: .infinity, alignment: .bottomTrailing)
    }
    
    func toggleBag(to state: Bool) {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            dishVM.isBagTapped = state
        }
    }
}

#Preview {
    PlayViewContainer(forGameMode: .singleplayer)
}
