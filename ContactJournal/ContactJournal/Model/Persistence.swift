//
//  Persistence.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 14.10.20.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ContactJournal")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    static func deleteDeprecatedItems() {
        let context = shared.container.viewContext
        do {
            let items = try context.fetch(Item.fetchRequest)
            items.filter({ $0.isDeprecated }).forEach(context.delete)
            try context.save()
        } catch (let error as NSError) {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    static func duplicate(item: Item) {
        let context = shared.container.viewContext
        let newItem = Item(context: context)
        
        newItem.timestamp = item.timestamp
        newItem.contactDetails = item.contactDetails
        newItem.couldKeepDistance = item.couldKeepDistance
        newItem.content = item.content
        newItem.durationHours = item.durationHours
        newItem.didWearMask = item.didWearMask
        newItem.isOutside = item.isOutside
        newItem.personCount = item.personCount
        newItem.isAllDay = item.isAllDay
        newItem.riskLevel = item.riskLevel
        newItem.location = item.location
        
        saveContext()
    }
    
    static func saveContext() {
        let context = shared.container.viewContext
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}


extension PersistenceController {
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.content = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
}
