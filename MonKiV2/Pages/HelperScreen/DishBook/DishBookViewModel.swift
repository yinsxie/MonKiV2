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
internal class DishBookViewModel: ObservableObject {
    @Published var currentPageIndex: Int = 0
    
    private let context = CoreDataManager.shared.viewContext
    
    func nextPage(totalCount: Int) -> Bool {
        if currentPageIndex + 2 < totalCount {
            withAnimation(.easeInOut) {
                currentPageIndex += 2
            }
            return true
        }
        return false
    }
    
    func prevPage() -> Bool {
        if currentPageIndex - 2 >= 0 {
            withAnimation(.easeInOut) {
                currentPageIndex -= 2
            }
            return true
        }
        return false
    }
    
    func deleteDish(_ dish: Dish, currentTotalCount: Int) {
        context.delete(dish)
        CoreDataManager.shared.save()
        
        let newTotalCount = currentTotalCount - 1
        
        withAnimation {
            if currentPageIndex >= newTotalCount && currentPageIndex > 0 {
                currentPageIndex = max(0, currentPageIndex - 2)
            }
        }
    }
    
    func resetNewDishFlag() {
        let userDefaults = UserDefaultsManager.shared
        userDefaults.setIsNewDishSaved(false)
    }
}
