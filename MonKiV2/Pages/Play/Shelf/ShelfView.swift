//
//  ShelfView.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//
import SwiftUI

struct ShelfView: View {
    @Environment(ShelfViewModel.self) var viewModel
    
    private let carrotItem = Item.items.first { $0.name == "Carrot" }
    private let tomatoItem = Item.items.first { $0.name == "Tomato" }
    private let broccoliItem = Item.items.first { $0.name == "Broccoli" }
    private let cornItem = Item.items.first { $0.name == "Corn" }
    private let eggItem = Item.items.first { $0.name == "Egg" }
    
    var body: some View {
        GeometryReader { geo in
            let backgroundSplitHeight = geo.size.height * (753 / 1024.0)
            let shelfBottomPadding = geo.size.height - (backgroundSplitHeight + 40)
            
            ZStack(alignment: .bottom) {
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image("scaler")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 489)
                            .padding(.trailing, 230)
                    }
                    .padding(.bottom, 370)
                    Spacer()
                }
                
                // shelves
                VStack(alignment: .leading, spacing: -45) {
                    HStack {
                        ZStack(alignment: .top) {
                            Image("shelf_jagung")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 377)
                            
                            if let cornItem = cornItem {
                                Rectangle()
                                    .foregroundColor(Color(hex: "FFE4B1"))
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Text(cornItem.price.description)
                                            .font(.wendyOne(size: 40))
                                            .foregroundColor(Color.black)
                                        )
                                    .offset(x: -150, y: 150)
                                
                                Color.clear
                                    .frame(width: 377, height: 150)
                                //  .background(Color.green.opacity(0.2))
                                    .contentShape(Rectangle())
                                    .makeDraggable(
                                        item: DraggedItem(
                                            payload: .grocery(cornItem)
                                        )
                                    )
                            }
                        }
                        
                        ZStack(alignment: .top) {
                            Image("shelf_wortel")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 377)
                            if let carrotItem = carrotItem {
                                Rectangle()
                                    .foregroundColor(Color(hex: "FFE4B1"))
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Text(carrotItem.price.description)
                                            .font(.wendyOne(size: 40))
                                            .foregroundColor(Color.black)
                                        )
                                    .offset(x: -150, y: 150)
                                
                                Color.clear
                                    .frame(width: 377, height: 150)
                                //  .background(Color.green.opacity(0.2))
                                    .contentShape(Rectangle())
                                    .makeDraggable(
                                        item: DraggedItem(
                                            payload: .grocery(carrotItem)
                                        )
                                    )
                            }
                        }
                    }
                    
                    HStack {
                        ZStack(alignment: .top) {
                            Image("shelf_tomat")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 377)
                            if let tomatoItem = tomatoItem {
                                Rectangle()
                                    .foregroundColor(Color(hex: "FFE4B1"))
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Text(tomatoItem.price.description)
                                            .font(.wendyOne(size: 40))
                                            .foregroundColor(Color.black)
                                        )
                                    .offset(x: -150, y: 120)
                                
                                Color.clear
                                    .frame(width: 377, height: 150)
                                //  .background(Color.green.opacity(0.2))
                                    .contentShape(Rectangle())
                                    .makeDraggable(
                                        item: DraggedItem(
                                            payload: .grocery(tomatoItem)
                                        )
                                    )}
                        }
                        
                        ZStack(alignment: .top) {
                            Image("shelf_brokoli")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 377)
                            if let broccoliItem = broccoliItem {
                                Rectangle()
                                    .foregroundColor(Color(hex: "FFE4B1"))
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Text(broccoliItem.price.description)
                                            .font(.wendyOne(size: 40))
                                            .foregroundColor(Color.black)
                                        )
                                    .offset(x: -150, y: 135)
                                
                                Color.clear
                                    .frame(width: 377, height: 150)
                                //                                .background(Color.green.opacity(0.2))
                                    .contentShape(Rectangle())
                                    .makeDraggable(
                                        item: DraggedItem(
                                            payload: .grocery(broccoliItem)
                                        )
                                    )
                            }
                        }
                        
                        ZStack(alignment: .top) {
                            Image("shelf_telur")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 251)
                            if let eggItem = eggItem {
                                Rectangle()
                                    .foregroundColor(Color(hex: "FFE4B1"))
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Text(eggItem.price.description)
                                            .font(.wendyOne(size: 40))
                                            .foregroundColor(Color.black)
                                        )
                                    .offset(x: -80, y: 110)
                                
                                Color.clear
                                    .frame(width: 251, height: 100)
                                //  .background(Color.green.opacity(0.2))
                                    .contentShape(Rectangle())
                                    .makeDraggable(
                                        item: DraggedItem(
                                            payload: .grocery(eggItem)
                                        )
                                    )
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, shelfBottomPadding)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    PlayViewContainer()
        .environmentObject(AppCoordinator())
}
