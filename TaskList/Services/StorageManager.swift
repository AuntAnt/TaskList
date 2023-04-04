//
//  StorageManager.swift
//  TaskList
//
//  Created by Anton Kuzmin on 03.04.2023.
//

import CoreData

final class StorageManager {
    static let shared = StorageManager()
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() { }
    
    //MARK: - CRUD methods
    func fetchData() -> [Task] {
        let fetchRequest = Task.fetchRequest()
        
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print(error)
        }
        
        return []
    }
    
    func saveTask(_ taskName: String) -> Task {
        let task = Task(context: context)
        task.title = taskName
        
        saveContext()
        return task
    }
    
    func updateTask(_ task: Task, with taskName: String) {
        task.title = taskName
        saveContext()
    }
    
    func delete(task: Task) {
        context.delete(task)
        saveContext()
    }
    
    // MARK: - Core Data Saving support
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
