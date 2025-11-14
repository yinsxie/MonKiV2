//
//  CreateDishView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 13/11/25.
//

import SwiftUI

struct CreateDishView: View {
    @ObservedObject var viewModel: CreateDishViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator

    var body: some View {
        HStack(spacing: 20) {
            // Ingredients List, bisa diganti nanti sesuai design
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Ingredients")
                    .font(.title2.bold())

                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(viewModel.ingredientList, id: \.self) { item in
                            Text("• \(item.capitalized)")
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)

            // Generated Image
            DishImageView(viewModel: viewModel)
                .frame(maxWidth: .infinity)
        }
        .padding()
        .onAppear {
            if viewModel.cgImage == nil && !viewModel.checkCheckoutItems() {
                viewModel.generate()
            }
        }
    }
}
