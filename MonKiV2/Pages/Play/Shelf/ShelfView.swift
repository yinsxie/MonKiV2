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
                VStack(alignment: .leading, spacing: -85) {
                    HStack(alignment: .bottom) {
                        ZStack(alignment: .top) {
                            Image("shelf_jagung")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 377)
                                .spotlight(id: "CornItem")
                            
                            if let cornItem = cornItem {
                                Color.clear
                                    .frame(width: 377, height: 180)
//                                  .background(Color.green.opacity(0.5))
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
                                .spotlight(id: "CarrotItem")
                            
                            if let carrotItem = carrotItem {
                                
                                Color.clear
                                    .frame(width: 377, height: 155)
//                                    .background(Color.green.opacity(0.5))
                                    .contentShape(Rectangle())
                                    .makeDraggable(
                                        item: DraggedItem(
                                            payload: .grocery(carrotItem)
                                        )
                                    )
                            }
                        }
                    }
                    
                    HStack(alignment: .bottom) {
                        ZStack(alignment: .top) {
                            VStack {
                                Image("shelf_tomat")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 377)
                                    .spotlight(id: "TomatoItem")
                                
                                Image("shelf_tomat_2")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 377)
                            }
                            
                            if let tomatoItem = tomatoItem {
                                
                                Color.clear
                                    .frame(width: 377, height: 200)
//                                    .background(Color.green.opacity(0.5))
                                    .contentShape(Rectangle())
                                    .makeDraggable(
                                        item: DraggedItem(
                                            payload: .grocery(tomatoItem)
                                        )
                                    )
                                    .padding(.top, 25)
                            }
                        }
                        
                        ZStack(alignment: .top) {
                            VStack {
                                Image("shelf_brokoli")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 377)
                                    .spotlight(id: "BroccoliItem")
                                
                                Image("shelf_brokoli_2")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 377)
                            }
                            
                            if let broccoliItem = broccoliItem {
                                
                                Color.clear
                                    .frame(width: 377, height: 220)
//                                    .background(Color.green.opacity(0.5))
                                    .contentShape(Rectangle())
                                    .makeDraggable(
                                        item: DraggedItem(
                                            payload: .grocery(broccoliItem)
                                        )
                                    )
                                    .padding(.top, 30)
                            }
                        }
                        
                        ZStack(alignment: .top) {
                            VStack {
                                Image("shelf_telur")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 251)
                                    .spotlight(id: "EggItem")
                                
                                Image("shelf_telur_2")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 251)
                            }
                            
                            if let eggItem = eggItem {
                                Color.clear
                                    .frame(width: 251, height: 180)
//                                    .background(Color.green.opacity(0.5))
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
                .padding(.bottom, shelfBottomPadding)
                
                Color.clear
                    .frame(width: 1050, height: 400)
                //                    .background(Color.green.opacity(0.3))
                    .contentShape(Rectangle())
                    .allowsHitTesting(false)
                    .makeDropZone(type: .shelfReturnItem)
                    .padding(.bottom, shelfBottomPadding+190)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    PlayViewContainer()
        .environmentObject(AppCoordinator())
}
