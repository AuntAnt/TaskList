//
//  StorageManager.swift
//  TaskList
//
//  Created by Anton Kuzmin on 03.04.2023.
//

import CoreData

enum CoreDataError: Error {
    case wrongEntityType
}

final class StorageManager {
    static let shared = StorageManager()
    
    // MARK: - Core Data stack
    private let persistentContainer: NSPersistentContainer = {
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
    func fetchData(completion: @escaping (Result<[Task], CoreDataError>) -> Void) {
        let fetchRequest = Task.fetchRequest()
        
        do {
            let tasks = try context.fetch(fetchRequest)
            completion(.success(tasks))
        } catch {
            completion(.failure(.wrongEntityType))
        }
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
