//
//  Exporter.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 21.10.20.
//

import Foundation
import CoreData

struct Exporter {
    private static let exportFilePath = NSTemporaryDirectory() + "Kontakte.csv"
    public static let exportFileURL = URL(fileURLWithPath: exportFilePath)
    
    private static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }
    
    private static func fetchAllItems() -> [Item] {
        let context = PersistenceController.shared.container.viewContext
        do {
            return try context.fetch(Item.fetchRequest)
        } catch (let error as NSError) {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    private static func csvStringFrom(items: [Item]) -> String {
        var csvString = "Datum, Beschreibung\n"
        for item in items {
            csvString.append("\"\(dateFormatter.string(from: item.timestamp))\"") // Datum
            csvString.append(",\"\(item.content)\"") // Beschreibung
            csvString.append("\n")
        }
        return csvString
     }
     
    public static func generateCSVExport() {
        let items = fetchAllItems()
        let csvString = csvStringFrom(items: items)
        guard let csvData = csvString.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
            fatalError("Could not encode CSV String to data")
        }
        
        do {
            try csvData.write(to: exportFileURL)
        } catch {
            fatalError(error.localizedDescription)
        }
     }
}
