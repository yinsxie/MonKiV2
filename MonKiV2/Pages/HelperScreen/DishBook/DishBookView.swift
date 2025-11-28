//
//  DishBookView.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 19/11/25.
//

import SwiftUI
import CoreData

struct DishBookView: View {
    @StateObject private var viewModel = DishBookViewModel()
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    @FetchRequest(
        entity: Dish.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Dish.timestamp, ascending: false)]
    ) var dishes: FetchedResults<Dish>
    
    // Constants for gesture detection sensitivity
    let minSwipeDistance: CGFloat = 30
    let maxVerticalOffset: CGFloat = 40
    
    var body: some View {
        ZStack {
            // A. Background
            Image("bookBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(edges: .all)
            
            // B. The Arrow page turn
            HStack {
                ArrowButton(direction: .left, action: { _ = viewModel.prevPage() })
                    .opacity(viewModel.currentPageIndex > 0 ? 1 : 0)
                    .padding(.horizontal, 26)
                
                Spacer()
                
                ArrowButton(direction: .right, action: { _ = viewModel.nextPage(totalCount: dishes.count) })
                    .opacity(viewModel.currentPageIndex + 2 < dishes.count ? 1 : 0)
                    .padding(.horizontal, 25)
            }
            
            // C. The Book Content (Centered)
            BookSpreadView(
                currentPageIndex: viewModel.currentPageIndex,
                totalCount: dishes.count,
                getDish: getDish,
                onDelete: deleteDish
            )
            
            // C. Navigation Overlay (Topmost Z-Index)
            VStack {
                HStack {
                    ReturnButton(action: {
                        appCoordinator.popLast()
                    })
                    .accessibilityLabel("Kembali ke halaman sebelumnya")
                    .padding(.leading, 82)
                    .padding(.top, 82)
                    Spacer()
                }
                Spacer()
            }
        }
        .onAppear {
            viewModel.resetNewDishFlag()
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    handleSwipe(value: value)
                }
        )
        
    }
    
    func handleSwipe(value: DragGesture.Value) {
        // Calculate the difference in position from start to end
        let horizontalDistance = value.translation.width
        let verticalOffset = value.translation.height
        
        // 1. Check if the movement was primarily horizontal (not a vertical scroll)
        guard abs(verticalOffset) < maxVerticalOffset else {
            return
        }
        
        // 2. Check for a significant horizontal distance
        if abs(horizontalDistance) > minSwipeDistance {
            if horizontalDistance < 0 {
                // Horizontal distance is negative -> SWIPE LEFT
                if viewModel.nextPage(totalCount: dishes.count) {
                    AudioManager.shared.play(.pageTurn, volume: 5.0)
                }
                
            } else {
                // Horizontal distance is positive -> SWIPE RIGHT
                if viewModel.prevPage() {
                    AudioManager.shared.play(.pageTurn, volume: 5.0)
                }
            }
            
        } else {
            print("No Significant Swipe!")
        }
    }
    
    // MARK: - Logic Helpers
    private func getDish(at index: Int) -> Dish? {
        if index >= 0 && index < dishes.count {
            return dishes[index]
        }
        return nil
    }
    
    private func deleteDish(_ dish: Dish) {
        viewModel.deleteDish(dish, currentTotalCount: dishes.count)
    }
}

struct BookSpreadView: View {
    let currentPageIndex: Int
    let totalCount: Int
    let getDish: (Int) -> Dish?
    let onDelete: (Dish) -> Void
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                // LEFT PAGE CONTAINER
                RecipePageView(
                    dish: getDish(currentPageIndex),
                    pageNumber: currentPageIndex + 1,
                    onDelete: onDelete
                )
                
                // RIGHT PAGE CONTAINER
                RecipePageView(
                    dish: getDish(currentPageIndex + 1),
                    pageNumber: currentPageIndex + 2,
                    onDelete: onDelete
                )
            }
            .frame(height: 776)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

// MARK: - Page Content Views
struct RecipePageView: View {
    let dish: Dish?
    let pageNumber: Int
    let onDelete: (Dish) -> Void
    
    var body: some View {
        ZStack(alignment: .top) {
            
            if let dish = dish {
                VStack(spacing: 0) {
                    
                    DishHeaderView(dish: dish, onDelete: onDelete)
                        .zIndex(1)
                    
                    Spacer().frame(minHeight: 20, maxHeight: 70)
                    
                    VStack(spacing: 20) {
                        MoneyBreakdownView(totalPrice: Int(dish.totalPrice))
                        
                        IngredientsGridView(ingredients: dish.ingredients)
                    }
                    
                    Spacer()
                }
                .padding(.top, 90)
                .padding(.horizontal, 20)
                
                // 3. Page Number
                VStack {
                    Spacer()
                    PageNumberView(number: pageNumber)
                        .padding(.bottom, 50)
                }
                
            } else {
                EmptyStateView(pageNumber: pageNumber)
            }
        }
        .frame(width: 540, height: 776)
        .clipped()
    }
}

struct DishHeaderView: View {
    let dish: Dish
    let onDelete: (Dish) -> Void
    
    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                Group {
                    if let fileName = dish.imageFileName,
                       let uiImage = ImageStorage.loadImage(from: fileName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 280, height: 280)
                            .clipped()
                            .accessibilityLabel("Dish photo")
                    } else {
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.white)
                            .frame(width: 280, height: 280)
                            .overlay(Image(systemName: "photo").foregroundColor(.gray))
                            .accessibilityLabel("No photo available for this dish")
                    }
                }
                
                //                Button(action: {
                //                    AudioManager.shared.play(.buttonClick)
                //                    onDelete(dish)
                //                }, label: {
                //                    Image("removeButton")
                //                        .resizable()
                //                        .scaledToFit()
                //                        .frame(width: 72, height: 72)
                //                })
                
                HoldButton(type: .remove, size: 72, strokeWidth: 6, onComplete: {
                    onDelete(dish)
                })
                .offset(x: 20, y: -20)
                .accessibilityLabel("Delete dish")
                
                PriceTag(price: dish.totalPrice)
                    .offset(x: 60, y: 250)
                    .rotationEffect(Angle(degrees: 2.42))
                
            }
        }
    }
}

struct MoneyBreakdownView: View {
    let totalPrice: Int
    
    var body: some View {
        HStack(spacing: -30) {
            let breakdown = Currency.breakdown(from: totalPrice)
            ForEach(breakdown.indices, id: \.self) { index in
                let currency = breakdown[index]
                Image(currency.imageAssetPath)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80)
                    .rotationEffect(.degrees(Double.random(in: -5...5)))
                    .shadow(radius: 2)
            }
        }
        .frame(height: 50)
        .padding(.bottom, 10)
    }
}

struct IngredientsGridView: View {
    let ingredients: NSSet?
    
    var body: some View {
        let ingredientsSet = ingredients as? Set<Ingredient> ?? []
        let sorted = ingredientsSet.sorted { $0.name ?? "" < $1.name ?? "" }
        let allItems = Array(sorted.prefix(14))
        
        let firstRow = Array(allItems.prefix(7))
        let secondRow = Array(allItems.dropFirst(7))
        
        VStack {
            if !allItems.isEmpty {
                VStack(spacing: 10) {
                    if !firstRow.isEmpty {
                        HStack(spacing: 8) {
                            ForEach(firstRow, id: \.self) { ing in
                                IngredientItemView(ingredient: ing)
                            }
                        }
                    }
                    
                    if !secondRow.isEmpty {
                        HStack(spacing: 8) {
                            ForEach(secondRow, id: \.self) { ing in
                                IngredientItemView(ingredient: ing)
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
}

struct IngredientItemView: View {
    let ingredient: Ingredient
    
    var body: some View {
        let itemName = ingredient.name ?? ""
        let matchedItem = Item.items.first(where: { $0.name == itemName })
        let itemPath = matchedItem?.imageAssetPath ?? ""
        let assetName = itemPath.isEmpty ? "wortel" : itemPath
        
        VStack(spacing: 0) {
            // Icon + Quantity Bubble
            ZStack(alignment: .top) {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .shadow(radius: 1)
                
                CircleNumberView(number: Int(ingredient.quantity))
                    .scaleEffect(0.45)
                    .offset(y: 15)
                
                // TODO: Remove when all shelf item assets are in
                //                Text(itemName)
                //                    .font(.fredokaOne(size: 14))
                //                    .foregroundColor(.black.opacity(0.8))
                //                    .lineLimit(1)
                //                    .fixedSize()
            }
            .frame(width: 48, height: 70)
        }
    }
}

struct EmptyStateView: View {
    let pageNumber: Int
    
    var body: some View {
        ZStack(alignment: .top) {
            
            Image("emptyState")
                .resizable()
                .scaledToFit()
                .frame(height: 615)
                .padding(.top, 50)
                .padding(.horizontal, 20)
            
            // 3. Page Number
            VStack {
                Spacer()
                PageNumberView(number: pageNumber)
                    .padding(.bottom, 50)
            }
            
        }
        .frame(width: 540, height: 776)
        .clipped()
    }
}

struct PageNumberView: View {
    let number: Int
    
    var body: some View {
        Text("- \(number) -")
            .font(.fredokaOne(size: 16))
            .foregroundColor(ColorPalette.dishBookPageNumber)
    }
}

struct ArrowButton: View {
    enum Direction { case left, right }
    let direction: Direction
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            AudioManager.shared.play(.pageTurn, volume: 5.0)
            action()
        }, label: {
            Image("arrowButton")
                .resizable()
                .scaledToFit()
                .frame(width: 122, height: 122)
                .scaleEffect(x: direction == .left ? -1 : 1, y: 1)
        })
    }
}

struct ReturnButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            AudioManager.shared.play(.buttonClick)
            action()
        }, label: {
            Image("returnButton")
                .resizable()
                .scaledToFit()
                .frame(width: 122, height: 122)
        })
    }
}

// MARK: - Preview
#Preview {
    DishBookView()
        .environmentObject(AppCoordinator())
    //        .environment(\.managedObjectContext, CoreDataManager.shared.viewContext)
}
