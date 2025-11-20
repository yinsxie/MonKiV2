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
        VStack {
            imageDisplayBox
                .frame(width: 600, height: 600)
                .padding(.top, 115)
                .overlay(alignment: .top) {
                    ZStack {
                        Image("extractor_hood")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 395)
                        
                        Rectangle()
                            .fill(Color(hex: "#65C466"))
                            .frame(width: 172, height: 47)
                            .overlay(
                                Text("\(viewModel.totalPurchasedPrice)")
                                    .font(.wendyOne(size: 40))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
                            )
                            .allowsHitTesting(false)
                            .padding(.top, 40)
                    }
                }
                .overlay(alignment: .bottom) {
                    VStack(spacing: 10) {
                        Button {
                            //MARK: Ideally make 1 function in viewModel
                            viewModel.isStartCookingTapped = false
                            //TODO: Store the image and ingredients to core data and image storage
                            //Remove the item used for image gen
                            viewModel.createDishItem.removeAll()
                        } label: {
                            Text("Simpan")
                        }
                        bottomButton
                            .padding(.horizontal, 16)
                            .offset(y: 50)
                    }
                }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
    
    // MARK: - Image Display Box
    private var imageDisplayBox: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 83)
                .fill(Color.white)
                .frame(width: 600, height: 600)
            
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
            .frame(width: 555, height: 555)
        }
        .frame(width: 600, height: 600)
    }
    
    // MARK: - Bottom Button
    // MARK: - Bottom Button
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
            AudioManager.shared.play(.buttonClick)
            viewModel.setIngredients(from: viewModel.createDishItem)
            // 2. Start generating
            viewModel.generate()
            
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
                        Text(hasImage ? "New Dish" : "Start Cook")
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
