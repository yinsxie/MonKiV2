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
            
            ZStack(alignment: .bottom){
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
                
                VStack(spacing: 20) {
                    HStack(spacing: 20) {
                        // --- PREV BUTTON ---
                        ArrowButton(direction: .left, action: viewModel.prevPage)
                            .opacity(viewModel.currentPageIndex > 0 ? 1 : 0)
                        
                        // --- THE OPEN BOOK ---
                        ZStack {
                            HStack(spacing: 0) {
                                // LEFT PAGE
                                ZStack () {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .background(Color(red: 1, green: 0.96, blue: 0.81))
                                    
                                    Image("bookPageShadow")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                    
                                    RecipePageView(
                                        dish: getDish(at: viewModel.currentPageIndex),
                                        pageNumber: viewModel.currentPageIndex + 1,
                                        onDelete: { dish in
                                            viewModel.deleteDish(dish, currentTotalCount: dishes.count)
                                        }
                                    )
                                }
                                .frame(width: 540, height: 776)
                                
                                // SPINE
                                Rectangle()
                                    .fill(Color(red: 0.53, green: 0.41, blue: 0))
                                    .frame(width: 2)
                                    .zIndex(1)
                                
                                // RIGHT PAGE
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: 540, height: 776)
                                        .background(Color(red: 1, green: 0.96, blue: 0.81))
                                    
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
                                    
                                    RecipePageView(
                                        dish: getDish(at: viewModel.currentPageIndex + 1),
                                        pageNumber: viewModel.currentPageIndex + 2,
                                        onDelete: { dish in
                                            viewModel.deleteDish(dish, currentTotalCount: dishes.count)
                                        }
                                    )
                                }
                                .frame(width: 540, height: 776)
                                
                            }
                            .frame(height: 776)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            VStack(spacing: 208){
                                Image("binderRing")
                                    .resizable()
                                    .scaledToFit()
                                Image("binderRing")
                                    .resizable()
                                    .scaledToFit()
                            }
                            .frame(width: 57)
                        }
                        
                        // --- NEXT BUTTON ---
                        ArrowButton(direction: .right, action: { viewModel.nextPage(totalCount: dishes.count) })
                            .opacity(viewModel.currentPageIndex + 2 < dishes.count ? 1 : 0)
                    }
                }
            }
        }
    }
    
    // Helper to get dish safely
    private func getDish(at index: Int) -> Dish? {
        if index >= 0 && index < dishes.count {
            return dishes[index]
        }
        return nil
    }
}

// MARK: - Single Page View
struct RecipePageView: View {
    let dish: Dish?
    let pageNumber: Int
    let onDelete: (Dish) -> Void
    
    var body: some View {
        GeometryReader { geo in
            if let dish = dish {
                VStack(spacing: 15) {
                    
                    // 1. Image Area
                    ZStack(alignment: .topTrailing) {
                        
                        Group {
                            if let fileName = dish.imageFileName,
                               let uiImage = ImageStorage.loadImage(from: fileName) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 260, height: 260)
                                    .clipped()
                            } else {
                                RoundedRectangle(cornerRadius: 0)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 240, height: 240)
                                    .overlay(Image(systemName: "photo").foregroundColor(.gray))
                            }
                        }
                        .padding(24)
                        .background(Color.white)
                        .rotationEffect(.degrees(-4))
                        
                        // Delete Button
                        Button(action: {
                            onDelete(dish)
                        }) {
                            Image("removeButton")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 72, height: 72)
                        }
                        .offset(x: 20, y: -20)
                        
                        // Price Text
                        Text("\(dish.totalPrice) Coins")
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                            .padding(.trailing, 10)
                            .padding(.bottom, 0)
                        
                    }
                    .frame(height: 380)
                    
                    // 2. Visual Money Breakdown
                    HStack(spacing: -30) {
                        let breakdown = Currency.breakdown(from: Int(dish.totalPrice))
                        
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
                    
                    // 3. Ingredients List
                    VStack(alignment: .leading, spacing: 10) {
                        
                        if let ingredientsSet = dish.ingredients as? Set<Ingredient> {
                            let sorted = ingredientsSet.sorted { $0.name ?? "" < $1.name ?? "" }
                            
                            ForEach(sorted, id: \.self) { ing in
                                HStack(spacing: 12) {
                                    let itemName = ing.name ?? ""
                                    let matchedItem = Item.items.first(where: { $0.name == itemName })
                                    let itemPath = matchedItem?.imageAssetPath ?? ""
                                    let assetName = itemPath.isEmpty ? "wortel" : itemPath
                                
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
                                                Text("\(ing.quantity)")
                                                    .font(.fredoka(.regular, size: 16))
                                                  .foregroundColor(Color(red: 1, green: 0.37, blue: 0.08))
                                            )
                                    }
                                    
                                    Text(itemName)
                                        .font(.system(.body, design: .serif))
                                        .foregroundColor(.black.opacity(0.8))
                                }
                            }
                        } else {
                            Text("No ingredients recorded")
                                .font(.caption)
                                .italic()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    // 4. Page Number
                    Text("\(pageNumber)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            } else {
                // EMPTY PAGE STATE
                VStack {
                    Spacer()
                    Image(systemName: "pencil.and.scribble")
                        .font(.system(size: 50))
                        .foregroundColor(.gray.opacity(0.3))
                    Text("Empty Page")
                        .font(.headline)
                        .foregroundColor(.gray.opacity(0.3))
                    Spacer()
                    Text("\(pageNumber)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .frame(width: 540, height: 776)
        .clipped()
    }
}

// MARK: - Navigation Button Helper
struct ArrowButton: View {
    enum Direction { case left, right }
    let direction: Direction
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: direction == .left ? "chevron.left" : "chevron.right")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)
                .padding()
                .background(Circle().fill(Color.white.opacity(0.2)))
        }
    }
}

// MARK: - Preview
#Preview {
    DishBookView()
        .environment(\.managedObjectContext, CoreDataManager.preview.viewContext)
}
