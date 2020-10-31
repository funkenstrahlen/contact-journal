//
//  ItemRow.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 14.10.20.
//

import SwiftUI
import CoreData

struct ItemRow: View {
    @ObservedObject var item: Item
    @Environment(\.managedObjectContext) private var viewContext
    
    private var dateAndTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d. MMM HH:mm"
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d. MMM"
        return formatter
    }
    
    private var realtimeRelativeTime: String {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        if Calendar.current.isDateInToday(item.timestamp) { return "heute" }
        if Calendar.current.isDateInYesterday(item.timestamp) { return "gestern" }
        let diffInDays = Calendar.current.dateComponents([.day], from: startOfDay, to: Calendar.current.startOfDay(for: item.timestamp)).day!
        if item.timestamp > Date() {
            return "in \(abs(diffInDays)) Tagen"
        } else {
            return "vor \(abs(diffInDays)) Tagen"
        }
    }
    
    private var dateString: String {
        if item.isAllDay {
            return dateFormatter.string(from: item.timestamp)
        }
        return dateAndTimeFormatter.string(from: item.timestamp)
    }
    
    var body: some View {
        if !item.isFault {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(dateString).font(.headline)
                    Spacer()
                    Text(realtimeRelativeTime).foregroundColor(.secondary)
                }.font(.subheadline)
                if(item.content == "") {
                    Text("Neuer Eintrag").foregroundColor(.secondary).italic()
                } else {
                    Text(item.content).lineLimit(2)
                }
                HStack {
                    item.riskLevel.icon.foregroundColor(item.riskLevel.color)
                    Text("\(item.personCount) \(item.personCount > 1 ? "Personen" : "Person")")
                }.font(.subheadline)
            }
            .contextMenu {
                Button(action: duplicateItem) {
                    Label("Duplizieren", systemImage: "plus.square.on.square")
                }
                Divider()
                Button(action: deleteItem) {
                    Label("Löschen", systemImage: "trash")
                }
            }
            .padding([.vertical], 8)
        }
    }
    
    private func duplicateItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            
            newItem.contactDetails = item.contactDetails
            newItem.couldKeepDistance = item.couldKeepDistance
            newItem.content = item.content
            newItem.durationHours = item.durationHours
            newItem.didWearMask = item.didWearMask
            newItem.isOutside = item.isOutside
            newItem.personCount = item.personCount
            newItem.isAllDay = item.isAllDay
            newItem.riskLevel = item.riskLevel
            
            PersistenceController.saveContext()
        }
    }
    
    private func deleteItem() {
        withAnimation {
            viewContext.delete(item)
            PersistenceController.saveContext()
        }
    }
}

struct ItemRow_Previews: PreviewProvider {
    static var item: Item {
        let item = Item(context: PersistenceController.preview.container.viewContext)
        item.content = "Kochen bei Pia mit meinen Freunden"
        item.isOutside = true
        item.didWearMask = true
        item.personCount = 15
        item.durationHours = 2.5
        return item
    }
    
    static var newItem: Item {
        let item = Item(context: PersistenceController.preview.container.viewContext)
        return item
    }
    
    static var previews: some View {
        NavigationView {
            List {
                ItemRow(item: item)
                ItemRow(item: item)
                ItemRow(item: item)
                ItemRow(item: item)
                ItemRow(item: newItem)
            }.navigationBarTitle("Kontakt-Tagebuch")
        }
    }
}
