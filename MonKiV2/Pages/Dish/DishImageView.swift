//
//  DishImageView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 13/11/25.
//

import SwiftUI

struct DishImageView: View {
    @ObservedObject var viewModel: CreateDishViewModel
    
    var body: some View {
        ZStack {
            // Background placeholder
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.2))
                .overlay(
                    Group {
                        if let cgImage = viewModel.cgImage {
                            Image(uiImage: UIImage(cgImage: cgImage))
                                .resizable()
                                .scaledToFit()
                        } else {
                            VStack {
                                Image(systemName: "photo")
                                    .font(.system(size: 50))
                                    .foregroundColor(.secondary)
                                Text(viewModel.isLoading ? "Generating..." : "No image yet")
                                    .foregroundColor(.secondary)
                                    .font(.title3)
                            }
                        }
                    }
                )
            
            // Loading overlay
            if viewModel.isLoading {
                Color.black.opacity(0.4)
                    .overlay(ProgressView().progressViewStyle(.circular).scaleEffect(1.5))
            }
            
            // Refresh button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        viewModel.generate()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.blue.opacity(0.8))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .disabled(viewModel.checkCheckoutItems())
                }
                .padding(12)
                Spacer()
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.3), lineWidth: 2))
    }
}
