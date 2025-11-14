//
//  IngredientInputView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 13/11/25.
//

// MARK: delete later, for testing input ingredients for generate image
import SwiftUI

struct IngredientInputView: View {
    @ObservedObject var viewModel: CreateDishViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State private var randomIngredientCount: Int = 3
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Add Ingredients")
                .font(.largeTitle.bold())
            
            TextField("egg, tomato, basil...", text: $viewModel.inputText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .submitLabel(.done)
                .autocorrectionDisabled(true)
                .keyboardType(.alphabet)
            
            Button("Create Dish") {
                viewModel.generate()
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.ingredientList.isEmpty)
            
            HStack {
                Stepper("Amount: \(randomIngredientCount)", value: $randomIngredientCount, in: 1...10)
                Spacer()
                
                Button {
                    viewModel.generateRandomIngredients(count: randomIngredientCount)
                } label: {
                    Image(systemName: "wand.and.stars")
                    Text("Magic")
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            
            List(viewModel.ingredientList, id: \.self) { item in
                Text("• \(item.capitalized)")
            }
            .listStyle(.plain)
            
            Spacer()
        }
        .padding()
    }
}
