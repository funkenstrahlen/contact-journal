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
    public class var fetchRequest: NSFetchRequest<Item> {
        NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var timestamp: Date?
    @NSManaged public var content: String
    @NSManaged public var isOutside: Bool
    @NSManaged public var didWearMask: Bool
    @NSManaged public var couldKeepDistance: Bool
    @NSManaged public var durationHours: Double
    @NSManaged public var personCount: Int64
    @NSManaged public var contactDetails: String
    @NSManaged public var riskLevel: RiskLevel
    @NSManaged public var isAllDay: Bool
    @NSManaged public var location: String
    @NSManaged public var notes: String
}

extension Item : Identifiable {

}

extension Item {
    public var isDeprecated: Bool {
        guard let timestamp = timestamp else { return false }
        let tresholdDate = Calendar.current.date(byAdding: .day, value: -21, to: Date())!
        return timestamp < tresholdDate
    }
}
