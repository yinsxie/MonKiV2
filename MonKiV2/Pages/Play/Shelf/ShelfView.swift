//
//  ShelfView.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//
import SwiftUI

struct ShelfView: View {
    @Environment(ShelfViewModel.self) var viewModel
    
    var body: some View {
        VStack {
            Text("Pick an Item")
                .font(.title)
                .padding(.top, 50)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                ForEach(viewModel.items) { item in
                    GroceryItemView(item: item)
                    
                    .makeDraggable(
                        item: DraggedItem(
                            id: item.id,
                            payload: .grocery(item)
                        )
                    )
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.orange.opacity(0.1))
    }
}
