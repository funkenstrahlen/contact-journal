//
//  Item+CoreData.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 14.10.20.
//

import Foundation
import CoreData

@objc(Item)
public class Item: NSManagedObject {

}

extension Item {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var timestamp: Date
    @NSManaged public var content: String
}

extension Item : Identifiable {

}

extension Item {
    public var isDeprecated: Bool {
        let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: Date())!
        return timestamp < twoWeeksAgo
    }
}
