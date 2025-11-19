//
//  CoreDataManager.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 19/11/25.
//
import Foundation
import CoreData
import Combine

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }

    private init() {
        container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }

    func save() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving Core Data: \(error.localizedDescription)")
            }
        }
    }
}


//TODO: remove before PR, this is for dummy preview dev
extension CoreDataManager {
    static var preview: CoreDataManager = {
        let result = CoreDataManager()
        let viewContext = result.container.viewContext
        
        // --- Create Fake Data for Preview ---
        for i in 0..<4 {
            let newDish = Dish(context: viewContext)
            newDish.id = UUID()
            newDish.timestamp = Date()
            newDish.totalPrice = Int32((Int.random(in: 15...60)))
            newDish.imageFileName = "mock_file_name" // Won't load real image, but shows logic
            
            // Add fake ingredients
            let ing1 = Ingredient(context: viewContext)
            ing1.name = "Rice"
            ing1.quantity = 2
            ing1.dish = newDish
            
            let ing2 = Ingredient(context: viewContext)
            ing2.name = "Egg"
            ing2.quantity = 1
            ing2.dish = newDish
        }
        // ------------------------------------
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
}
