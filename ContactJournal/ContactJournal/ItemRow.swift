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
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    private var dateString: String {
        guard let timestamp = item.timestamp else { return "" }
        if item.isAllDay {
            return "Ganzer Tag"
        }
        return dateAndTimeFormatter.string(from: timestamp)
    }
    
    private var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter
    }
    
    private var duration: String {
        if item.isAllDay {
            return "24"
        }
        return numberFormatter.string(from: NSNumber(value: item.durationHours))!
    }
    
    var body: some View {
        if !item.isFault {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    item.riskLevel.icon.foregroundColor(item.riskLevel.color)
                    Text(dateString)
                    Spacer()
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                            Text("\(duration) h")
                        }
                        HStack(spacing: 4) {
                            Image(systemName: "person")
                            Text("\(item.personCount)")
                        }
                    }
                    .foregroundColor(.secondary)
                }.font(.subheadline)
                
                if(item.content == "") {
                    Text("Neuer Eintrag").foregroundColor(.secondary).italic()
                } else {
                    Text(item.content).lineLimit(2)
                }
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
            PersistenceController.duplicate(item: item)
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
