//
//  StorageManager.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 28.02.26.
//

import CoreData
import UIKit

final class StorageManager {
    static let shared = StorageManager()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "FavouritesModel")
            container.loadPersistentStores { _, error in
                if let error = error as NSError? {
                    print("Core Data failed: \(error)")
                }
            }
            return container
        }()

        var context: NSManagedObjectContext {
            persistentContainer.viewContext
        }

        
        func saveLike(id: String) {
            let like = LikeEntity(context: context)
            like.id = id
            saveContext()
        }

        func removeLike(id: String) {
            let fetchRequest: NSFetchRequest<LikeEntity> = LikeEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            
            do {
                let results = try context.fetch(fetchRequest)
                results.forEach { context.delete($0) }
                saveContext()
            } catch {
                print("Delete error: \(error)")
            }
        }

        func fetchAllLikes() -> [String] {
            let fetchRequest: NSFetchRequest<LikeEntity> = LikeEntity.fetchRequest()
            do {
                let results = try context.fetch(fetchRequest)
                return results.compactMap { $0.id }
            } catch {
                return []
            }
        }

        private func saveContext() {
            if context.hasChanges {
                try? context.save()
            }
        }
    }

