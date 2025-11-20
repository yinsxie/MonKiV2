//
//  CreateDishView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 13/11/25.
//

import SwiftUI

struct CreateDishView: View {
    @Environment(CreateDishViewModel.self) var viewModel
    @Environment(DragManager.self) var dragManager
    
    var body: some View {
        ZStack {
            
            VStack(alignment: .leading) {
                monkiFace
                
                ZStack {
                    Color.green.opacity(0.4)
                    
                    HStack {
                        ForEach(viewModel.createDishItem) { cartItem in
                            GroceryItemView(item: cartItem.item)
                                .opacity(dragManager.currentDraggedItem?.id == cartItem.id && dragManager.currentDraggedItem?.source == .createDish ? 0 : 1)
                            
                                .makeDraggable(item: DraggedItem(id: cartItem.id, payload: .grocery(cartItem.item), source: .createDish))
                            
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Color.clear.makeDropZone(type: .createDish)
                }
                .frame(width: 700, height: 300)
                
                bottomButton
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 30)
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
            //            DishImageView() .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
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
    
    private var bottomButton: some View {
        // This function returns true if the input text is EMPTY
        let isInputEmpty = viewModel.checkCheckoutItems()
        let hasImage = viewModel.cgImage != nil
        
        // The button is disabled if:
        // 1. We are currently loading (isLoading == true)
        // 2. We have NO image generated yet AND the input is empty
        //    (meaning no purchased items were loaded)
        let isDisabled = viewModel.isLoading || (!hasImage && isInputEmpty)
        
        return Button(action: {
            // MODIFIED ACTION:
            // 1. Always get the fresh list of purchased items
            viewModel.isStartCookingTapped = true
            AudioManager.shared.play(.buttonClick)
            if let createDishItem = viewModel.parent?.dishVM.createDishItem {
                viewModel.setIngredients(from: createDishItem)
            }
            // 2. Start generating
//            viewModel.generate()
            viewModel.generateMock()
            
        }) {
            ZStack {
                Image(isDisabled ? "button_disable" : "button_active")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .scaleEffect(1.5)
                } else {
                    HStack(spacing: 10) {
                        // MODIFIED: Text changes based on hasImage
                        Text("New Dish")
                            .font(.wendyOne(size: 40))
                            .foregroundColor(.white)
                        
                        Image("Spatula")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                    }
                    .shadow(color: .black.opacity(0.2), radius: 2, y: 2)
                }
            }
        }
        .disabled(isDisabled) // Use the new isDisabled logic
    }
}

#Preview {
    PlayViewContainer()
}
