//
//  ItemRow.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 14.10.20.
//

import SwiftUI
import CoreData

struct ItemRow: View {
    var item: Item
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d. MMM HH:mm"
        return formatter
    }()
    
    private var realtimeRelativeTime: String {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        if Calendar.current.isDateInToday(item.timestamp) { return "heute" }
        if Calendar.current.isDateInYesterday(item.timestamp) { return "gestern" }
        let diffInDays = Calendar.current.dateComponents([.day], from: startOfDay, to: Calendar.current.startOfDay(for: item.timestamp)).day!
        return "vor \(abs(diffInDays)) Tagen"
    }
    
    var body: some View {
        NavigationLink(destination: EditView(item: item)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text("\(item.timestamp, formatter: dateFormatter)")
                    Spacer()
                    Text(realtimeRelativeTime).foregroundColor(.secondary)
                }.font(.subheadline)
                if(item.content == "") {
                    Text("Neuer Eintrag").foregroundColor(.secondary).italic()
                } else {
                    Text(item.content).lineLimit(2)
                }
                HStack {
                    Text("\(item.didWearMask ? "😷" : "🙂")")
                    Text("\(item.isOutside ? "🌤" : "🏠")")
                    Text("\(item.personCount) \(item.personCount > 1 ? "Personen" : "Person")")
                    Text("\(item.durationHours, specifier: "%g") h")
                }.font(.subheadline)
            }
            .padding([.vertical], 8)
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
            }.navigationBarTitle("Kontakt Tagebuch")
        }
    }
}
