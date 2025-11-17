//
//  IngredientInputView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 17/11/25.
//

// MARK: delete later, for testing input ingredients for generate image
import SwiftUI

struct IngredientInputView: View {
    @Environment(CreateDishViewModel.self) var viewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State private var allItems: [Item] = Item.items
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible())
    ]

    private var currentQuantities: [UUID: Int] {
        guard let cashierVM = viewModel.parent?.cashierVM else { return [:] }
        
        let grouped = Dictionary(grouping: cashierVM.purchasedItems, by: { $0.item.id })
        
        return grouped.mapValues { $0.count }
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("Debug Item Selector")
                .font(.largeTitle.bold())
                .padding(.bottom, 24)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(allItems) { item in
                        VStack(alignment: .leading, spacing: 12) {
                            
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                    .lineLimit(1)
                                Text("Price: \(item.price)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            HStack {
                                Text("Qty:")
                                    .font(.caption.weight(.medium))
                                Spacer()
                                
                                Text("\(currentQuantities[item.id] ?? 0)")
                                    .font(.headline.monospacedDigit())
                                    .frame(width: 40, alignment: .center)
                                
                                Stepper("Quantity", value: Binding<Int>(
                                    get: { currentQuantities[item.id] ?? 0 },
                                    set: { newValue in
                                        let oldValue = currentQuantities[item.id] ?? 0
                                        
                                        if newValue > oldValue {
                                            addItemToPurchase(item)
                                        } else if newValue < oldValue {
                                            removeItemFromPurchase(item)
                                        }
                                    }
                                ), in: 0...99)
                                .labelsHidden()
                            }
                        }
                        .padding()
                        .background(Color(.systemGroupedBackground))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding([.horizontal, .bottom], 32)
        .padding(.top, 128)
    }
    
    private func addItemToPurchase(_ item: Item) {
        guard let cashierVM = viewModel.parent?.cashierVM else { return }
        
        DispatchQueue.main.async {
            cashierVM.purchasedItems.append(CartItem(item: item))
            print("Added 1 \(item.name) to purchased items.")
        }
    }
    
    private func removeItemFromPurchase(_ item: Item) {
        guard let cashierVM = viewModel.parent?.cashierVM else { return }
        
        if let index = cashierVM.purchasedItems.firstIndex(where: { $0.item.id == item.id }) {
            DispatchQueue.main.async {
                cashierVM.purchasedItems.remove(at: index)
                print("Removed 1 \(item.name) from purchased items.")
            }
        }
    }
}
