//
//  Exporter.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 21.10.20.
//

import Foundation
import CoreData

struct Exporter {
    private static let exportFilePath = NSTemporaryDirectory() + "Kontakt-Tagebuch.csv"
    public static let exportFileURL = URL(fileURLWithPath: exportFilePath)
    
    private static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .short
        return dateFormatter
    }
    
    private static var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter
    }
    
    private static func fetchAllItems() -> [Item] {
        let context = PersistenceController.shared.container.viewContext
        let request = Item.fetchRequest
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)]
        do {
            return try context.fetch(request)
        } catch (let error as NSError) {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    private static func csvStringFrom(items: [Item]) -> String {
        // header
        var csvString = "Datum, Beschreibung, Ort, Mund-Nasen-Bedeckung getragen, Abstand gehalten, Dauer (Stunden), Personenzahl, Empfundenes Ansteckungsrisiko, Kontaktdetails\n"
        for item in items {
            csvString.append("\"\(dateFormatter.string(from: item.timestamp))\"")
            csvString.append(",\(item.content.escapedForCSV)")
            csvString.append(",\(item.isOutside ? "Draußen" : "Drinnen")")
            csvString.append(",\(item.didWearMask ? "Ja" : "Nein")")
            csvString.append(",\(item.couldKeepDistance ? "Ja" : "Nein")")
            csvString.append(",\"\(numberFormatter.string(from: NSNumber(value: item.durationHours))!)\"")
            csvString.append(",\(item.personCount)")
            csvString.append(",\(item.riskLevel.localizedDescription)")
            csvString.append(",\(item.contactDetails.escapedForCSV)")
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

extension String {
    fileprivate var escapedForCSV: String {
        return "\"" + self
            .replacingOccurrences(of: "\n", with: "\r")
            .replacingOccurrences(of: "\"", with: "\"\"")
        + "\""
    }
}
