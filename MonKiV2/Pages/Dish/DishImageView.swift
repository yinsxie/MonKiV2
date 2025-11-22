//
//  DishImageView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 13/11/25.
//

import SwiftUI

struct DishImageView: View {
    @Environment(CreateDishViewModel.self) var viewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            HStack(alignment: .center, spacing: 72) {
                ZStack(alignment: .topLeading) {
                    imageDisplay
                    
                    let isInputEmpty = viewModel.checkCheckoutItems()
                    let hasImage = viewModel.cgImage != nil
                    let isDisabled = viewModel.isLoading || (!hasImage && isInputEmpty)
                    
                    if !isDisabled {
                        retryButton
                            .offset(x: -20, y: -20)
                    }
                }
                
                Image("dividerLine")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 6)
                
                VStack(alignment: .center, spacing: 24) {
                    MoneyBreakdownView(totalPrice: viewModel.totalPurchasedPrice)
                    ingredientsGrid
                }
                .padding(0)
                .frame(width: 432, alignment: .center)
            }
            .padding(48)
            .frame(width: 1160, height: 584, alignment: .center)
            .background(Color(red: 1, green: 0.94, blue: 0.8))
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .inset(by: -12)
                    .stroke(.white, lineWidth: 24)
            )
            
            saveButton
                .offset(y: 70)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
    
    // MARK: - Image Display
    private var imageDisplay: some View {
        ZStack {
            if let cgImage = viewModel.cgImage {
                Image(uiImage: UIImage(cgImage: cgImage))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            
            // LOADING OVERLAY
            if viewModel.isLoading {
                Color.black.opacity(0.4)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(1.5)
                            .tint(.white)
                    )
            }
        }
        .frame(width: 488, height: 488)
        
    }
    
    // MARK: - Ingredients Grid (Grouped)
    private var ingredientsGrid: some View {
        let sortedItems = viewModel.groupedDishItems
        let limitedItems = Array(sortedItems.prefix(14))
        
        let firstRow = Array(limitedItems.prefix(7))
        let secondRow = Array(limitedItems.dropFirst(7))
        
        return VStack {
            if !limitedItems.isEmpty {
                VStack(spacing: 10) {
                    if !firstRow.isEmpty {
                        HStack(spacing: 8) {
                            ForEach(firstRow) { groceryItem in
                                ingredientItemView(groceryItem)
                            }
                        }
                    }
                    
                    if !secondRow.isEmpty {
                        HStack(spacing: 8) {
                            ForEach(secondRow) { groceryItem in
                                ingredientItemView(groceryItem)
                            }
                        }
                    }
                }
            }
        }
        .frame(height: 190)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 40)
    }
    
    // MARK: - Helper: Item View
    private func ingredientItemView(_ groceryItem: GroceryItem) -> some View {
        let itemName = groceryItem.item.name
        let itemPath = groceryItem.item.imageAssetPath
        let assetName = itemPath.isEmpty ? "wortel" : itemPath
        
        let quantity = groceryItem.quantity
        
        return VStack(spacing: 0) {
            ZStack(alignment: .top) {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .shadow(radius: 1)
                
                if quantity > 0 {
                    CircleNumberView(number: quantity)
                        .scaleEffect(0.45)
                        .offset(y: 15)
                }
            }
            .frame(width: 48, height: 70)
        }
    }
    
    // MARK: - Retry Button
    private var retryButton: some View {
        
        return Button(action: {
            AudioManager.shared.play(.buttonClick)
            viewModel.setIngredients(from: viewModel.createDishItem)
            viewModel.generate()
        }, label: {
            ZStack {
                Image("retryButton")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 132)
            }
        })
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        let isInputEmpty = viewModel.checkCheckoutItems()
        let hasImage = viewModel.cgImage != nil
        let isDisabled = viewModel.isLoading || (!hasImage && isInputEmpty)
        
        return Button(action: {
            viewModel.onSaveButtonTapped()
        }, label: {
            ZStack {
                Image(isDisabled ? "button_disable" : "button_active")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 127)
                
                    HStack(spacing: 10) {
                        Text("Simpan Resep")
                            .font(.fredokaOne(size: 40))
                            .foregroundColor(.white)
                        
                        Image("bookDownloadIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 36)
                    }
            }
        })
        .disabled(isDisabled)
    }
}
