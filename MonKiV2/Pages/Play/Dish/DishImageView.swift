//
//  DishImageView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 13/11/25.
//

import SwiftUI

struct DishImageView: View {
    @Environment(CreateDishViewModel.self) var viewModel
    @Environment(PlayViewModel.self) var playVM
    
    var body: some View {
        ZStack(alignment: .bottom) {
            HStack(alignment: .center, spacing: 72) {
                ZStack(alignment: .topLeading) {
                    imageDisplay
                    
                    let isInputEmpty = viewModel.checkCheckoutItems()
                    let hasImage = viewModel.cgImage != nil
                    let isDisabled = viewModel.isLoading || (!hasImage && isInputEmpty) || (!viewModel.isShowMultiplayerDish && playVM.gameMode == .multiplayer) ||
                    (playVM.gameMode == .multiplayer && viewModel.isLocalReadySaveImage)
                    
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
            
            HStack (spacing: 40) {
                saveButton
                
                if playVM.gameMode == .multiplayer {
                    Text("\(viewModel.amountOfPlayerReadyToSaveImage)/2")
                        .font(.fredokaSemiBold(size: 35))
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 15).fill(.white))
                }
            }
            .offset(y: 70)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .onChange(of: viewModel.isShowMultiplayerDish) { _, newValue in
            if newValue == false { return }
            AudioManager.shared.stop(.loadCooking)
            AudioManager.shared.play(.dishDone, pitchVariation: 0.03)
        }
        .onChange(of: viewModel.isBothReadyToSaveImage) { _, newValue in
            if newValue {
                viewModel.saveMultiplayerDishImageToBook()
            }
        }
    }
    
    // MARK: - Image Display
    private var imageDisplay: some View {
        ZStack {
            if let cgImage = viewModel.cgImage {
                if viewModel.isShowMultiplayerDish || playVM.gameMode == .singleplayer {
                    Image(uiImage: UIImage(cgImage: cgImage))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }
            }
            
            // LOADING OVERLAY
            // State nunggu temen
            if !viewModel.isRemotePlayerStartCookingTapped && playVM.gameMode == .multiplayer {
                // TODO: Bikin animasi custom nunggu temen
                Text("Nunggu temen....")
            } else if viewModel.isLoading || (!viewModel.isShowMultiplayerDish && playVM.gameMode == .multiplayer) {
                // State animasi loading makanan
                // TODO: Bikin animasi loading custom
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
            
            if playVM.gameMode == .singleplayer {
                viewModel.setIngredients(from: viewModel.createDishItem)
                viewModel.cgImage = nil
                viewModel.generate()
                return
            }
            
            //Handle multiplayer
            playVM.matchManager?.sendHideMultiplayerDish()
            
            viewModel.whoTappedLast = .me
            viewModel.generateInitialMultiplayerDish()
        }, label: {
            ZStack {
                Image("retryButton")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 132)
            }
        })
        .accessibilityLabel("Coba lagi untuk menghasilkan gambar resep")
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        let isInputEmpty = viewModel.checkCheckoutItems()
        let hasImage = viewModel.cgImage != nil
        
        var text: String {
            if playVM.gameMode == .multiplayer {
                
                if viewModel.isLocalReadySaveImage {
                    return "Batal"
                }
                
                if !viewModel.isRemotePlayerStartCookingTapped {
                    return "Kembali"
                }
                if !viewModel.isShowMultiplayerDish {
                    return "Memasak..."
                }
                
                return hasImage ? "Simpan Resep" : "Memasak..."
            }
            return "Simpan Resep"
        }
        
        var isDisabled: Bool {
            
            if playVM.gameMode == .singleplayer {
                return viewModel.isLoading || (!hasImage && isInputEmpty)
            }
            
            if text == "Batal" {
                return false
            }
            
            if text == "Kembali" {
                return false
            }
            
            if text == "Memasak..." {
                return true
            }
            
            if text == "Simpan Resep" {
                return false
            }
            
            return viewModel.isLoading || (!hasImage && isInputEmpty)
        }
        
        var imageName: String {
            if playVM.gameMode == .multiplayer {
                switch text {
                case "Simpan Resep":
                    return "button_active"
                case "Memasak...", "Kembali", "Batal":
                    return "button_loading"
                default:
                    return "button_disable"
                }
            }
            return isDisabled ? "button_disable" : "button_active"
        }
        
        var iconName: String {
            switch text {
            case "Simpan Resep":
                return "bookDownloadIcon"
            case "Memasak...":
                return "loadingCreateDishIcon"
            default:
                return ""
            }
        }
        
        return Button(action: {
            AudioManager.shared.play(.buttonClick)
            
            if playVM.gameMode == .singleplayer {
                viewModel.onSaveButtonTapped()
                return
            }
            
            // Handle multiplayer
            // If the remote player has not started cooking, go back, make it unready"
            if text == "Kembali" {
                viewModel.onBackButtonTapped()
                return
            } else if text == "Simpan Resep" || text == "Batal" {
                viewModel.onMultiplayerSaveButtonToggled()
            }
            
        }, label: {
            ZStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 127)
                
                HStack(spacing: 10) {
                    Text(text)
                        .font(.fredokaSemiBold(size: 40))
                        .foregroundColor(.white)
                    
                    if !iconName.isEmpty {
                        Image(iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 36)
                    }
                }
            }
        })
        .disabled(isDisabled)
    }
}

#Preview {
    PlayViewContainer(forGameMode: .singleplayer, chef: .pasta)
}
