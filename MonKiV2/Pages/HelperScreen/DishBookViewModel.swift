//
//  DishBookViewModel.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 19/11/25.
//
import SwiftUI
import CoreData
import Combine

// MARK: - View Model
class DishBookViewModel: ObservableObject {
    @Published var currentPageIndex: Int = 0
    
    // We access the singleton directly here for simplicity in the VM
    private let context = CoreDataManager.shared.viewContext
    
    func nextPage(totalCount: Int) {
        withAnimation(.easeInOut) {
            if currentPageIndex + 2 < totalCount {
                currentPageIndex += 2
            }
        }
    }
    
    func prevPage() {
        withAnimation(.easeInOut) {
            if currentPageIndex - 2 >= 0 {
                currentPageIndex -= 2
            }
        }
    }
    
    func deleteDish(_ dish: Dish, currentTotalCount: Int) {
        // 1. Delete from Core Data
        context.delete(dish)
        CoreDataManager.shared.save()
        
        // 2. Safety Check:
        // If we deleted the last item and the page is now empty, go back one page.
        // The 'currentTotalCount' passed here includes the item we just deleted,
        // so the NEW count is (currentTotalCount - 1).
        let newTotalCount = currentTotalCount - 1
        
        withAnimation {
            // If current index is now beyond the last available item, step back
            if currentPageIndex >= newTotalCount && currentPageIndex > 0 {
                currentPageIndex = max(0, currentPageIndex - 2)
            }
        }
    }
}
