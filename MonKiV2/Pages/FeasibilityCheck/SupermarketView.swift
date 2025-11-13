//
//  SupermarketView.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//

import SwiftUI

struct SupermarketView: View {
    @State private var viewModel = SupermarketViewModel()
    
    var body: some View {
        ZStack {
            // MARK: LAYER 1 - The Background / ScrollView
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    // PAGE 1: Shelves
                    ShelfPage(viewModel: viewModel)
                        .containerRelativeFrame(.horizontal) // Makes it full width of screen
                        .id(0)
                    
                    // PAGE 2: Checkout
                    CheckoutPage(viewModel: viewModel)
                        .containerRelativeFrame(.horizontal)
                        .id(1)
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: Binding(
                get: { viewModel.currentPageIndex },
                set: { val in viewModel.currentPageIndex = val ?? 0 }
            ))
            
            // MARK: LAYER 2 - The Cart (Static Overlay)
            VStack {
                Spacer()
                CartView(viewModel: viewModel)
                    .padding(.bottom, 50)
            }
            
            // MARK: LAYER 3 - The Dragging "Ghost"
            // This layer sits on top of everything so items don't get clipped
            if let item = viewModel.draggedItem {
                Image(systemName: item.icon)
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                    .position(viewModel.dragLocation) // Follows finger exactly
                    .allowsHitTesting(false) // Let touches pass through to underlying views
            }
        }
        .coordinateSpace(name: "shopArea") // Vital: Defines the global coordinate map
        .background(Color.gray.opacity(0.1))
    }
}

// MARK: - Subviews

struct ShelfPage: View {
    var viewModel: SupermarketViewModel
    
    var body: some View {
        VStack {
            Text("Aisle 1: Drag to Cart")
                .font(.largeTitle)
                .padding()
            
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                ForEach(viewModel.shelfItems) { item in
                    ItemView(item: item)
                        // THE DRAG GESTURE
                        .gesture(
                            DragGesture(coordinateSpace: .named("shopArea"))
                                .onChanged { value in
                                    viewModel.draggedItem = item
                                    viewModel.dragLocation = value.location
                                }
                                .onEnded { _ in
                                    withAnimation {
                                        viewModel.handleDrop()
                                    }
                                }
                        )
                        // Hide original while dragging to create "pickup" effect
                        .opacity(viewModel.draggedItem?.id == item.id ? 0 : 1)
                }
            }
            Spacer()
        }
        .background(Color.orange.opacity(0.1))
    }
}

struct CheckoutPage: View {
    var viewModel: SupermarketViewModel
    
    var body: some View {
        VStack {
            Text("Checkout Counter")
                .font(.largeTitle)
                .padding()
            
            // The Counter Area (Drop Zone)
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.brown)
                    .frame(height: 200)
                    .overlay(
                        Text("Drop items here")
                            .foregroundColor(.white)
                    )
                
                // Render items already on the counter
                HStack {
                    ForEach(viewModel.checkoutItems) { item in
                        Image(systemName: item.icon)
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(5)
                    }
                }
            }
            .padding()
            // Capture Frame for Collision Detection
            .background(
                GeometryGetter(update: { rect in
                    viewModel.checkoutFrame = rect
                })
            )
            
            Spacer()
        }
    }
}

struct CartView: View {
    var viewModel: SupermarketViewModel
    
    var body: some View {
        ZStack {
            // Cart Visual
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.blue.opacity(0.2))
                .frame(width: 250, height: 120)
                .overlay(
                    VStack {
                        Text("My Cart")
                            .font(.headline)
                        HStack {
                            ForEach(viewModel.cartItems) { item in
                                // If on Page 2, make these draggable
                                Group {
                                    if viewModel.currentPageIndex == 1 {
                                        ItemView(item: item)
                                            .gesture(
                                                DragGesture(coordinateSpace: .named("shopArea"))
                                                    .onChanged { value in
                                                        viewModel.draggedItem = item
                                                        viewModel.dragLocation = value.location
                                                    }
                                                    .onEnded { _ in
                                                        withAnimation {
                                                            viewModel.handleDrop()
                                                        }
                                                    }
                                            )
                                            .opacity(viewModel.draggedItem?.id == item.id ? 0 : 1)
                                    } else {
                                        // On Page 1, items in cart are static
                                        ItemView(item: item)
                                    }
                                }
                            }
                        }
                    }
                )
        }
        // Capture Frame for Collision Detection
        .background(
            GeometryGetter(update: { rect in
                viewModel.cartFrame = rect
            })
        )
    }
}

struct ItemView: View {
    let item: GroceryItem
    
    var body: some View {
        VStack {
            Image(systemName: item.icon)
                .font(.system(size: 40))
                .foregroundColor(.blue)
            Text(item.name)
                .font(.caption)
        }
        .frame(width: 80, height: 80)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview {
    SupermarketView()
}

struct GeometryGetter: View {
    let update: (CGRect) -> Void
    
    var body: some View {
        GeometryReader { geo in
            Color.clear
                .onAppear { update(geo.frame(in: .named("shopArea"))) }
                .onChange(of: geo.frame(in: .named("shopArea"))) { _, newValue in
                    update(newValue)
                }
        }
    }
}
