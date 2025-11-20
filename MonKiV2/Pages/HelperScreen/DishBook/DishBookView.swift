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
    
    var body: some View {
        ZStack {
            // A. Background
            Image("bookBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(edges: .all)
            
            // B. The Book Content (Centered)
            ZStack(alignment: .bottom) {
                // 1. The Static Cover Art
                BookCoverView()
                
                // 2. The Interactive Content
                VStack(spacing: 20) {
                    // The Open Book (Pages + Spine + Rings)
                    BookSpreadView(
                        currentPageIndex: viewModel.currentPageIndex,
                        totalCount: dishes.count,
                        getDish: getDish,
                        onDelete: deleteDish
                    )
                }
            }
            
            // C. Navigation Overlay (Topmost Z-Index)
            VStack {
                Spacer()
                HStack {
                    ArrowButton(direction: .left, action: viewModel.prevPage)
                        .opacity(viewModel.currentPageIndex > 0 ? 1 : 0)
                    
                    Spacer()
                    
                    ArrowButton(direction: .right, action: { viewModel.nextPage(totalCount: dishes.count) })
                        .opacity(viewModel.currentPageIndex + 2 < dishes.count ? 1 : 0)
                }
                .padding(.horizontal, 82)
                .padding(.bottom, 82)
            }
            
            VStack {
                HStack {
                    ReturnButton(action: {
                        appCoordinator.popLast()
                    })
                    .padding(.leading, 82)
                    .padding(.top, 82)
                    Spacer()
                }
                Spacer()
            }
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

// MARK: - Book Structure Subviews
struct BookCoverView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            // Outer Book Cover
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 1212, height: 776)
                .background(Color(red: 1, green: 0.79, blue: 0.01))
                .cornerRadius(8)
                .offset(x: 0, y: 22)
            
            // Inner Book Cover / Shadow
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 1158, height: 741)
                .background(Color(red: 0.35, green: 0.28, blue: 0.03))
                .cornerRadius(8)
                .opacity(0.5)
        }
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
                PageContainerView(isLeft: true) {
                    RecipePageView(
                        dish: getDish(currentPageIndex),
                        pageNumber: currentPageIndex + 1,
                        onDelete: onDelete
                    )
                }
                
                // SPINE
                Rectangle()
                    .fill(Color(red: 0.53, green: 0.41, blue: 0))
                    .frame(width: 2)
                    .zIndex(1)
                
                // RIGHT PAGE CONTAINER
                PageContainerView(isLeft: false) {
                    RecipePageView(
                        dish: getDish(currentPageIndex + 1),
                        pageNumber: currentPageIndex + 2,
                        onDelete: onDelete
                    )
                }
            }
            .frame(height: 776)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // BINDER RINGS OVERLAY
            BinderRingsView()
        }
    }
}

struct PageContainerView<Content: View>: View {
    let isLeft: Bool
    let content: Content
    
    init(isLeft: Bool, @ViewBuilder content: () -> Content) {
        self.isLeft = isLeft
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Paper Background
            Rectangle()
                .foregroundColor(.clear)
                .background(Color(red: 1, green: 0.96, blue: 0.81))
            
            // Shadow Effect
            if isLeft {
                Image("bookPageShadow")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } else {
                // Right page has dual shadows mirrored
                Image("bookPageShadow")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .scaleEffect(x: -1, y: 1)
                Image("bookPageShadow")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .scaleEffect(x: 1, y: -1)
            }
            
            content
        }
        .frame(width: 540, height: 776)
    }
}

struct BinderRingsView: View {
    var body: some View {
        VStack(spacing: 208) {
            Image("binderRing")
                .resizable()
                .scaledToFit()
            Image("binderRing")
                .resizable()
                .scaledToFit()
        }
        .frame(width: 57)
    }
}

// MARK: - Page Content Views
struct RecipePageView: View {
    let dish: Dish?
    let pageNumber: Int
    let onDelete: (Dish) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if let dish = dish {
                ZStack(alignment: .top) {
                    VStack(spacing: 70) {
                        // 1. Image Area
                        DishHeaderView(dish: dish, onDelete: onDelete)

                        VStack(spacing: 70) {
                            // 2. Visual Money Breakdown
                            MoneyBreakdownView(totalPrice: Int(dish.totalPrice))
                            
                            // 3. Ingredients List
                            IngredientsGridView(ingredients: dish.ingredients)
                        }
                        Spacer()
                    }
                    .frame(maxHeight: .infinity)
                    .padding(.bottom, 100)
                    .padding(.top, 100)

                    // 4. Page Number
                    VStack {
                        Spacer()
                        PageNumberView(number: pageNumber)
                            .padding(.bottom, 30)
                    }
                }
                .frame(width: 540, height: 776)
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
                    } else {
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.white)
                            .frame(width: 280, height: 280)
                            .overlay(Image(systemName: "photo").foregroundColor(.gray))
                    }
                }
                
                Button(action: {
                    AudioManager.shared.play(.buttonClick)
                    onDelete(dish)
                }, label: {
                    Image("removeButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                })
                .offset(x: 20, y: -20)
                
                Text("\(dish.totalPrice) Coins")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.black)
                    .offset(x: 0, y: 200)
                
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
        VStack(alignment: .center, spacing: 15) {
            if let ingredientsSet = ingredients as? Set<Ingredient> {
                
                let sorted = ingredientsSet.sorted { $0.name ?? "" < $1.name ?? "" }
                
                let allItems = Array(sorted.prefix(14))
                
                let firstRow = Array(allItems.prefix(7))
                let secondRow = Array(allItems.dropFirst(7))
                
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
                
            } else {
                Text("No ingredients recorded")
                    .font(.caption)
                    .italic()
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
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
            ZStack {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .shadow(radius: 1)
                
                Circle()
                    .frame(height: 32)
                    .foregroundColor(.white)
                    .overlay(
                        Text("\(ingredient.quantity)")
                            .font(.fredokaOne(size: 16))
                            .foregroundColor(.black)
                    )
                    .offset(x: 0, y: 30)
                
                Text(itemName)
                    .font(.fredokaOne(size: 16))
                    .foregroundColor(.black.opacity(0.8))
            }
        }
    }
}

struct EmptyStateView: View {
    let pageNumber: Int
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "pencil.and.scribble")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.3))
            Text("Empty Page")
                .font(.headline)
                .foregroundColor(.gray.opacity(0.3))
            Spacer()
            PageNumberView(number: pageNumber)
                .padding(.bottom, 20)
        }
    }
}

struct PageNumberView: View {
    let number: Int
    
    var body: some View {
        Text("- \(number) -")
            .font(.fredokaOne(size: 16))
            .foregroundColor(Color(red: 0.67, green: 0.54, blue: 0.02))
    }
}

struct ArrowButton: View {
    enum Direction { case left, right }
    let direction: Direction
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            AudioManager.shared.play(.buttonClick)
            action()
        }, label: {
            Image("arrowButton")
                .resizable()
                .scaledToFit()
                .frame(width: 122, height: 122)
                .scaleEffect(x: direction == .left ? 1 : -1, y: 1)
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
        .environment(\.managedObjectContext, CoreDataManager.shared.viewContext)
}
