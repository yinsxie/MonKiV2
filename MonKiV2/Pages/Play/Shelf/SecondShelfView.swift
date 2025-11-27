//
//  SecondShelfView.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 23/11/25.
//
import SwiftUI

struct SecondShelfView: View {
    @Environment(ShelfViewModel.self) var viewModel
    
    private let riceItem = Item.items.first { $0.name == "Rice" }
    private let pastaItem = Item.items.first { $0.name == "Pasta" }
    private let breadItem = Item.items.first { $0.name == "Bread" }
    private let milkItem = Item.items.first { $0.name == "Milk" }
    private let beefItem = Item.items.first { $0.name == "Beef" }
    private let fishItem = Item.items.first { $0.name == "Fish" }
    private let poultryItem = Item.items.first { $0.name == "Chicken" }
    
    let doorWidth: CGFloat = 217.83
    
    var body: some View {
        GeometryReader { geo in
            let backgroundSplitHeight = geo.size.height * (753 / 1024.0)
            let shelfBottomPadding = geo.size.height - (backgroundSplitHeight + 40)
            
            ZStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    
                    Spacer()
                    
                    HStack(alignment: .bottom, spacing: 13) {
                        
                        Spacer()
                        
                        ZStack {
                            Image("left_shelf")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 695)
                            
                            VStack(spacing: 20) {
                                if let breadItem = breadItem {
                                    Color.clear
                                        .frame(width: 377, height: 250)
                                    //                                        .background(Color.green.opacity(0.5))
                                        .contentShape(Rectangle())
                                        .makeDraggable(
                                            item: DraggedItem(
                                                payload: .grocery(breadItem)
                                            )
                                        )
                                }
                                if let milkItem = milkItem {
                                    Color.clear
                                        .frame(width: 377, height: 260)
                                    //                                        .background(Color.green.opacity(0.5))
                                        .contentShape(Rectangle())
                                        .makeDraggable(
                                            item: DraggedItem(
                                                payload: .grocery(milkItem)
                                            )
                                        )
                                }
                            }
                            .padding(.top, 60)
                        }
                        
                        ZStack {
                            Image("mid_shelf_frame")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 715)
                            
                            VStack(spacing: 26) {
                                Image("mid_shelf_top")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 410)
                                Image("mid_shelf_bottom")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 410)
                            }
                            .padding(.bottom, 20)
                            
                            VStack {
                                HStack {
                                    if let riceItem = riceItem {
                                        Color.clear
                                            .frame(width: 200, height: 230)
                                        //                                            .background(Color.green.opacity(0.5))
                                            .contentShape(Rectangle())
                                            .makeDraggable(
                                                item: DraggedItem(
                                                    payload: .grocery(riceItem)
                                                )
                                            )
                                    }
                                    if let pastaItem = pastaItem {
                                        Color.clear
                                            .frame(width: 200, height: 230)
                                        //                                            .background(Color.green.opacity(0.5))
                                            .contentShape(Rectangle())
                                            .makeDraggable(
                                                item: DraggedItem(
                                                    payload: .grocery(pastaItem)
                                                )
                                            )
                                    }
                                }
                                if let beefItem = beefItem {
                                    Color.clear
                                        .frame(width: 400, height: 180)
                                    //                                        .background(Color.green.opacity(0.5))
                                        .contentShape(Rectangle())
                                        .makeDraggable(
                                            item: DraggedItem(
                                                payload: .grocery(beefItem)
                                            )
                                        )
                                }
                            }
                            .padding(.bottom, 20)
                            
                            HStack(spacing: 0) {
                                
                                Image("pintu_kiri")
                                    .resizable()
                                    .scaledToFit()
                                    .rotation3DEffect(
                                        .degrees(viewModel.isSecondShelfLeftFridgeOpen ? -180 : 0),
                                        axis: (x: 0.0, y: 1.0, z: 0.0),
                                        anchor: .leading,
                                        perspective: 0.4
                                    )
                                    .onTapGesture {
                                        viewModel.animateLeftDoor()
                                    }
                                
                                Image("pintu_kanan")
                                    .resizable()
                                    .scaledToFit()
                                    .rotation3DEffect(
                                        .degrees(viewModel.isSecondShelfRightFridgeOpen ? 180 : 0),
                                        axis: (x: 0.0, y: 1.0, z: 0.0),
                                        anchor: .trailing,
                                        perspective: 0.4
                                    )
                                    .onTapGesture {
                                        viewModel.animateRightDoor()
                                    }
                            }
                            .padding(.bottom, 20)
                            .padding(.all, 50)
                        }
                        .zIndex(1)
                        
                        ZStack(alignment: .top) {
                            Image("right_shelf")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 400)
                            VStack {
                                if let fishItem = fishItem {
                                    Color.clear
                                        .frame(width: 400, height: 180)
                                    //                                        .background(Color.green.opacity(0.5))
                                        .contentShape(Rectangle())
                                        .makeDraggable(
                                            item: DraggedItem(
                                                payload: .grocery(fishItem)
                                            )
                                        )
                                }
                                if let poultryItem = poultryItem {
                                    Color.clear
                                        .frame(width: 400, height: 180)
                                    //                                        .background(Color.green.opacity(0.5))
                                        .contentShape(Rectangle())
                                        .makeDraggable(
                                            item: DraggedItem(
                                                payload: .grocery(poultryItem)
                                            )
                                        )
                                }
                            }
                        }
                        
                        Spacer()
                        
                    }
                }
                .padding(.bottom, shelfBottomPadding)
                
                HStack(alignment: .top) {
                    Color.clear
                        .frame(width: 350, height: 600)
                    //                        .background(Color.green.opacity(0.3))
                        .contentShape(Rectangle())
                        .allowsHitTesting(false)
                        .makeDropZone(type: .shelfReturnItem)
                        .padding(.bottom, shelfBottomPadding)
                    Color.clear
                        .frame(width: 890, height: 420)
                    //                        .background(Color.green.opacity(0.3))
                        .contentShape(Rectangle())
                        .allowsHitTesting(false)
                        .makeDropZone(type: .shelfReturnItem)
                        .padding(.bottom, shelfBottomPadding)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    PlayViewContainer(forGameMode: .singleplayer)
        .environmentObject(AppCoordinator())
}
