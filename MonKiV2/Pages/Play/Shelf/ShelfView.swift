//
//  ShelfView.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//
import SwiftUI

struct ShelfView: View {
    var viewModel: ShelfViewModel
    
    private let carrotItem = Item.items.first { $0.name == "Wortel" }
    private let tomatoItem = Item.items.first { $0.name == "Tomat" }
    private let broccoliItem = Item.items.first { $0.name == "Brokoli" }
    private let cornItem = Item.items.first { $0.name == "Jagung" }
    private let eggItem = Item.items.first { $0.name == "Telur" }
    
    var body: some View {
        VStack {
            Text("Pick an Item")
                .font(.title)
                .padding(.top, 50)
            
            HStack(alignment: .bottom){
                VStack {
                    ZStack(alignment: .top) {
                        Image("shelf_jagung")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 377)
                        
                        if let cornItem = cornItem {
                            Color.clear
                                .frame(width: 377, height: 150)
                                .background(Color.green.opacity(0.2))
                                .contentShape(Rectangle())
                                .makeDraggable(
                                    item: DraggedItem(
                                        payload: .grocery(cornItem)
                                    )
                                )
                        }
                    }
                    
                    ZStack(alignment: .top) {
                        Image("shelf_tomat")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 377)
                        if let tomatoItem = tomatoItem {
                            Color.clear
                                .frame(width: 377, height: 150)
                                .background(Color.green.opacity(0.2))
                                .contentShape(Rectangle())
                                .makeDraggable(
                                    item: DraggedItem(
                                        payload: .grocery(tomatoItem)
                                    )
                                )}
                    }
                }
                
                VStack {
                    ZStack(alignment: .top) {
                        Image("shelf_wortel")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 377)
                        if let carrotItem = carrotItem {
                            Color.clear
                                .frame(width: 377, height: 150)
                                .background(Color.green.opacity(0.2))
                                .contentShape(Rectangle())
                                .makeDraggable(
                                    item: DraggedItem(
                                        payload: .grocery(carrotItem)
                                    )
                                )
                        }
                    }
                    
                    ZStack(alignment: .top) {
                        Image("shelf_brokoli")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 377)
                        if let broccoliItem = broccoliItem {
                            Color.clear
                                .frame(width: 377, height: 150)
                                .background(Color.green.opacity(0.2))
                                .contentShape(Rectangle())
                                .makeDraggable(
                                    item: DraggedItem(
                                        payload: .grocery(broccoliItem)
                                    )
                                )
                        }
                    }
                }
                
                ZStack(alignment: .top) {
                    Image("shelf_telur")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 251)
                    if let eggItem = eggItem {
                        Color.clear
                            .frame(width: 251, height: 100)
                            .background(Color.green.opacity(0.2))
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    PlayViewContainer()
        .environmentObject(AppCoordinator())
}
