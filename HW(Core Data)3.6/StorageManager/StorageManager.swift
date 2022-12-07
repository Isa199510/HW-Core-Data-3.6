//
//  StorageManager.swift
//  HW(Core Data)3.6
//
//  Created by Иса on 06.12.2022.
//

import Foundation
import CoreData

class StorageManager {
    static let shared = StorageManager()
    private init() {}
    
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetch(completion: @escaping(Result<[Task], Error>) -> Void ) {
        let fetchRequest = Task.fetchRequest()
        do {
            let tasks = try persistentContainer.viewContext.fetch(fetchRequest)
            completion(.success(tasks))
        } catch {
            completion(.failure(error))
        }
    }
    
    func save(_ taskName: String, completion: @escaping(Result<Task, Error>) -> Void ) {
        let task = Task(context: persistentContainer.viewContext)
        task.title = taskName
        do {
            try persistentContainer.viewContext.save()
            completion(.success(task))
        } catch {
            completion(.failure(error))
        }
    }
    
    func delete(with task: Task) {
        persistentContainer.viewContext.delete(task)
        saveContext()
    }
    
    func update(with task: Task, newName: String) {
        task.title = newName
        saveContext()
    }
}
