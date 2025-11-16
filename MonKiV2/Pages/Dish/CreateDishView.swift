//
//  CreateDishView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 13/11/25.
//

import SwiftUI

struct CreateDishView: View {
    @Environment(CreateDishViewModel.self) var viewModel
    
    var body: some View {
        HStack(spacing: 20) {
            
            VStack(alignment: .center) {
                Spacer()
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
                Spacer()
                
                ShoppingBagView()
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .onAppear {
                if viewModel.cgImage == nil && viewModel.checkCheckoutItems(),
                   let purchasedItems = viewModel.parent?.cashierVM.purchasedItems,
                   !purchasedItems.isEmpty {
                    viewModel.setIngredients(from: purchasedItems)
                }
            }
            .onChange(of: viewModel.parent?.cashierVM.purchasedItems) { _, newPurchasedItems in
                if let purchasedItems = newPurchasedItems,
                   !purchasedItems.isEmpty &&
                    viewModel.cgImage == nil &&
                    viewModel.checkCheckoutItems() {
                    viewModel.setIngredients(from: purchasedItems)
                }
            }
            
            DishImageView()
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
    }
}
