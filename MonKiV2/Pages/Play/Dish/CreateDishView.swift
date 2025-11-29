//
//  CreateDishView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 13/11/25.
//

import SwiftUI

struct CreateDishView: View {
    @Environment(PlayViewModel.self) var playVM
    @Environment(CreateDishViewModel.self) var viewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    var body: some View {
        ZStack {
            // Main Content
            HStack(alignment: .bottom, spacing: 16) {
                ZStack {
                    MonkiCharacterView()
                        .offset(x: -160, y: 0)
                    
                    Image("tenant")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 837, height: 966)
                    
                    cookingStationArea
                }
                
                Image("rak")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 293, height: 370)
                    .offset(y: -120)
            }
            .offset(x: 75, y: -70)
            
            // 2. Tour Button Overlay Component
            if playVM.isIntroButtonVisible {
                TourButtonOverlay()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // Dishbook + Pot + Stove + Button
    private var cookingStationArea: some View {
        VStack(alignment: .center, spacing: 16) {
            HStack(alignment: .bottom, spacing: 0) {
                Button(action: {
                    AudioManager.shared.play(.buttonClick)
                    appCoordinator.goTo(.helperScreen(.dishBook))
                }, label: {
                    Image("dish_book")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 171, height: 204)
                })
                
                Spacer()
                
                VStack {
                    // 3. Ingredient Grid Component
                    IngredientDropZoneView()
                        .frame(width: 408, height: 231)
                        .padding(.bottom, -60)
                    
                    VStack(alignment: .center, spacing: 8) {
                        Image("panci_outline")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 400, height: 67)
                        
                        Image("kompor")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 321, height: 101)
                    }
                }
                
                Spacer()
            }
            .frame(width: 760)
            .padding(.leading, 16)
            //            .background(Color.red)
            
            // 4. Action Button Component
            CookActionButton()
                .padding(.leading, 180)
        }
        .frame(alignment: .center)
        .padding(.top, 56)
        .onAppear {
            if viewModel.cgImage == nil && viewModel.checkCheckoutItems(),
               let purchasedItems = viewModel.parent?.cashierVM.purchasedItems,
               !purchasedItems.isEmpty {
                viewModel.setIngredients(from: purchasedItems)
            }
        }
        .onChange(of: viewModel.createDishItem) { _, newPurchasedItems in
            if !newPurchasedItems.isEmpty &&
                viewModel.cgImage == nil &&
                viewModel.checkCheckoutItems() {
                viewModel.setIngredients(from: newPurchasedItems)
            }
        }
    }
}

// MARK: - Subviews

// 1. Monki Character View
struct MonkiCharacterView: View {
    @Environment(CreateDishViewModel.self) var viewModel
    
    var body: some View {
        ZStack {
            Image("chef_monki")
                .resizable()
                .scaledToFit()
                .frame(width: 413)
            
            ZStack(alignment: .center) {
                Image("speech_bubble")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 202)
                
                if viewModel.cgImage == nil {
                    Image("food_speech_bubble")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64)
                } else {
                    Text("Yummy")
                        .font(.wendyOne(size: 36))
                        .foregroundStyle(.black)
                }
            }
            .offset(x: 220, y: -200)
        }
    }
}

// 2. Ingredient Drop Zone & Grid View
struct IngredientDropZoneView: View {
    @Environment(CreateDishViewModel.self) var viewModel
    @Environment(DragManager.self) var dragManager
    
    var body: some View {
        ZStack {
            // Green background area
            Color.green.opacity(0)
            
            // 3-Row Item Grid
            VStack(alignment: .center, spacing: -50) {
                
                // ROW 3: Items 10-12
                if viewModel.createDishItem.count > 9 {
                    HStack(spacing: -44) {
                        ForEach(Array(viewModel.createDishItem.dropFirst(9).prefix(3))) { cartItem in
                            GroceryItemView(item: cartItem.item)
                                .scaleEffect(0.86)
                                .opacity(dragManager.currentDraggedItem?.id == cartItem.id && dragManager.currentDraggedItem?.source == .createDish ? 0 : 1)
                                .makeDraggable(
                                    item: DraggedItem(id: cartItem.id, payload: .grocery(cartItem.item), source: .createDish),
                                    onDragStarted: {
                                        viewModel.handleOnItemDraggedFromCreateDish(itemName: cartItem.item.name)
                                    }
                                )
                        }
                    }
                }
                
                // ROW 2: Items 6-9
                if viewModel.createDishItem.count > 5 {
                    HStack(spacing: -44) {
                        ForEach(Array(viewModel.createDishItem.dropFirst(5).prefix(4))) { cartItem in
                            GroceryItemView(item: cartItem.item)
                                .scaleEffect(0.86)
                                .opacity(dragManager.currentDraggedItem?.id == cartItem.id && dragManager.currentDraggedItem?.source == .createDish ? 0 : 1)
                                .makeDraggable(
                                    item: DraggedItem(id: cartItem.id, payload: .grocery(cartItem.item), source: .createDish),
                                    onDragStarted: {
                                        viewModel.handleOnItemDraggedFromCreateDish(itemName: cartItem.item.name)
                                    }
                                )
                        }
                    }
                }
                
                // ROW 1: Items 1-5
                if !viewModel.createDishItem.isEmpty {
                    HStack(spacing: -44) {
                        ForEach(Array(viewModel.createDishItem.prefix(5))) { cartItem in
                            GroceryItemView(item: cartItem.item)
                                .scaleEffect(0.86)
                                .opacity(dragManager.currentDraggedItem?.id == cartItem.id && dragManager.currentDraggedItem?.source == .createDish ? 0 : 1)
                                .makeDraggable(
                                    item: DraggedItem(id: cartItem.id, payload: .grocery(cartItem.item), source: .createDish),
                                    onDragStarted: {
                                        viewModel.handleOnItemDraggedFromCreateDish(itemName: cartItem.item.name)
                                    }
                                )
                        }
                    }
                }
            }
            .frame(width: 380, height: 220, alignment: .bottom)
            
            // Dropzone Overlay
            Color.clear.makeDropZone(type: .createDish)
        }
    }
}

// 3. Cook Action Button View
struct CookActionButton: View {
    @Environment(CreateDishViewModel.self) var viewModel
    @Environment(DragManager.self) var dragManager
    
    var body: some View {
        let isDisabled = viewModel.createDishItem.count == 0 || dragManager.isEitherPlayerDragging
        
        Button(action: {
            viewModel.isStartCookingTapped = true
            AudioManager.shared.play(.buttonClick)
            if let createDishItem = viewModel.parent?.dishVM.createDishItem {
                viewModel.setIngredients(from: createDishItem)
            }
            viewModel.generate()
        }, label: {
            ZStack {
                Image(isDisabled ? "button_disable" : "button_active")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 107)
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .scaleEffect(1.5)
                } else {
                    HStack(spacing: 10) {
                        Text("Masak Sekarang")
                            .font(.fredokaOne(size: 40))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.3)
                        
                        Image("Spatula")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                    }
                    .shadow(color: .black.opacity(0.2), radius: 2, y: 2)
                }
            }
        })
        .disabled(isDisabled)
    }
}

// 4. Tour Button Overlay View
struct TourButtonOverlay: View {
    @Environment(PlayViewModel.self) var playVM
    @Environment(CreateDishViewModel.self) var viewModel
    @Environment(DragManager.self) var dragManager
    
    var body: some View {
        Button(action: {
            playVM.startTour()
        }, label: {
            Image(viewModel.tourButtonImage)
                .resizable()
                .scaledToFit()
                .frame(width: 273, height: 123)
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .padding(.leading, 48)
        .padding(.bottom, 58)
        .onAppear {
            viewModel.startAutoLoopAnimation()
        }
        .onDisappear {
            viewModel.stopAutoLoopAnimation()
        }
        .disabled(dragManager.isDragging)
    }
    
    private var monkiFace: some View {
        ZStack {
            Image("chef_monki")
                .resizable()
                .scaledToFit()
                .frame(width: 413)
            
            ZStack(alignment: .center) {
                Image("speech_bubble")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 202)
                
                if viewModel.cgImage == nil {
                    Image("food_speech_bubble")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64)
                } else {
                    Text("Yummy")
                        .font(.wendyOne(size: 36))
                        .foregroundStyle(.black)
                }
            }
            .offset(x: 150, y: -100)
        }
    }
    
    private var dishBook: some View {
        //        RoundedRectangle(cornerRadius: 20)
        //            .fill(Color(hex: "#85DCFA"))
        //            .frame(width: 171, height: 205)
        Image("dish_book")
            .resizable()
            .scaledToFit()
            .frame(width: 160, height: 204)
            .rotationEffect(Angle(degrees: 5))
            .offset(y: 25)
    }
    
    private var bottomButton: some View {
        let isDisabled = viewModel.createDishItem.count == 0 || dragManager.isEitherPlayerDragging
        
        return Button(action: {
            // MODIFIED ACTION:
            // 1. Always get the fresh list of purchased items
            viewModel.isStartCookingTapped = true
            AudioManager.shared.play(.buttonClick)
            if let createDishItem = viewModel.parent?.dishVM.createDishItem {
                viewModel.setIngredients(from: createDishItem)
            }
            // 2. Start generating
            viewModel.generate()
        }, label: {
            ZStack {
                Image(isDisabled ? "button_disable" : "button_active")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 107)
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .scaleEffect(1.5)
                } else {
                    HStack(spacing: 10) {
                        // MODIFIED: Text changes based on hasImage
                        Text("Masak Sekarang")
                            .font(.fredokaSemiBold(size: 40))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.3)
                        
                        Image("Spatula")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 38)
                    }
                    .shadow(color: .black.opacity(0.2), radius: 2, y: 2)
                }
            }
        })
        .disabled(isDisabled) // Use the new isDisabled logic
    }
}

#Preview {
    PlayViewContainer(forGameMode: .singleplayer)
        .environmentObject(AppCoordinator())
}
