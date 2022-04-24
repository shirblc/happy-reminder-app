//
//  DataManager.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 22/04/2022.
//

import Foundation
import CoreData

class DataManager {
    // MARK: Variables
    var persistentContainer: NSPersistentContainer = NSPersistentContainer(name: "happierReminders")
    var viewContext: NSManagedObjectContext
    var backgroundContext: NSManagedObjectContext!
    
    // init
    init() {
        viewContext = persistentContainer.viewContext
        loadPersistentStore()
        backgroundContext = persistentContainer.newBackgroundContext()
        setupContexts()
    }
    
    // MARK: Setup methods
    // loadPersistentStore
    // Loads the persistent store
    func loadPersistentStore() {
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    // setupContexts
    // Does the setup for the contexts
    func setupContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump

        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }

    // MARK: Helper Methods
    // saveContext
    // Saves the context
    func saveContext (useViewContext: Bool, errorCallback: (Error) -> Void) {
        let context = useViewContext ? viewContext : backgroundContext
        
        if context!.hasChanges {
            do {
                try context!.save()
            } catch {
                errorCallback(error)
            }
        }
    }
    
    // saveAllContexts
    // Saves both contexts
    func saveAllContexts() {
        for value in [true, false] {
            self.saveContext(useViewContext: value) { error in
                print(error)
            }
        }
    }
}
